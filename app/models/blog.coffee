_ = require 'underscore'
clone = require 'clone'
errs = require 'errs'
mongoose = require 'mongoose'
extend = require 'mongoose-schema-extend'
app = require '../../app'
Author = require './author'
Article = require './article'
Taxonomy = require '../../lib/taxonomy'

# console.log(Article.baseSchema);

blogSchema = Article.baseSchema.extend
  blog : {type: String, required: true}
  tags: {type: [{type: String}], required: true}

blogSchema.pre('save', (next) ->
  this.updated = new Date
  next()
)

blogSchema.methods.addUrlForTitle = (callback) ->
  simpleUrl = URLify(@title)
  if @url?.match(new RegExp("^" + simpleUrl))
    return callback(null, @url)
  getAvailableUrl(simpleUrl, (err, url) =>
    if err then return errs.handle(err, callback)
    @urls.unshift(url)
    callback(null, @url)
  )

blogSchema.virtual('url').get -> @urls[0]

Blog = module.exports = app.db.model 'Blog', blogSchema


getAvailableUrl = (url, callback) ->
  urlPattern = new RegExp("^#{url}")
  Blog.find(urls: urlPattern).exec (err, blogPosts) ->
    if err then return errs.handle(err, callback)
    urlPattern = new RegExp("^#{url}(_(\\d+))?$")
    urls = (
      (blogUrl for blogUrl in blogPost.urls \
       when blogUrl.match urlPattern) for blogPost in blogPosts)
    last = _.last(_.flatten(urls).sort())
    if last
      number = last.match(urlPattern)[2]
      number = if number then JSON.parse(number) else 0
      url = url + '_' + (number + 1)
    callback(null, url)

# Stolen from http://snipt.net/jpartogi/slugify-javascript/
URLify = (s, maxChars) ->
  maxChars = 100 if not maxChars?
  removelist = ["a", "an", "as", "at", "before", "but", "by", "for", "from", "is", "in", "into", "like", "of", "off", "on", "onto", "per", "since", "than", "the", "this", "that", "to", "up", "via", "with"]
  r = new RegExp("\\b(" + removelist.join("|") + ")\\b", "gi")
  s = s.replace(r, "")
  s = s.replace(/[^-\w\s]/g, "") # remove unneeded chars
  s = s.replace(/^\s+|\s+$/g, "") # trim leading/trailing spaces
  s = s.replace(/[-\s]+/g, "-") # convert spaces to hyphens
  s = s.toLowerCase() # convert to lowercase
  s = s.substring 0, maxChars # trim to first num_chars chars
  s.replace(/\-$/, "")
