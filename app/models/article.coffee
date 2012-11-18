_ = require 'underscore'
errs = require 'errs'
mongoose = require 'mongoose'

app = require '../../app'
Author = require './author'
Image = require './image'
Taxonomy = require '../../lib/taxonomy'


imageSchema =
  image: {type: mongoose.Schema.Types.ObjectId, ref: 'Image'}
  id: mongoose.Schema.Types.ObjectId

articleSchema = new mongoose.Schema
  authors: {type: [{type: mongoose.Schema.Types.ObjectId, ref: 'Author'}], default: []}
  body: {type: String, required: true}
  created: {type: Date, default: Date.now, required: true}
  images:
    LargeRect: imageSchema
    ThumbRect: imageSchema
    ThumbRectL: imageSchema
    ThumbSquareM: imageSchema
    ThumbWide: imageSchema
  subtitle: String
  taxonomy: Taxonomy
  teaser: String
  title: {type: String, required: true}
  updated: {type: Date, default: Date.now, required: true}
  urls: {type: [{type: String, match: /[a-z_\d\-]/}], required: true}

articleSchema.pre('save', (next) ->
  this.updated = new Date
  next()
)

articleSchema.methods.addUrlForTitle = (callback) ->
  simpleUrl = URLify(@title)
  if @url?.match(new RegExp("^" + simpleUrl))
    return callback(null, @url)
  getAvailableUrl(simpleUrl, (err, url) =>
    if err then return errs.handle(err, callback)
    @urls.unshift(url)
    callback(null, @url)
  )

for version in ['LargeRect', 'ThumbRect', 'ThumbRectL', 'ThumbSquareM', 'ThumbWide']
  do (version=version) ->
    articleSchema.virtual("images.#{version}.version").get ->
      return undefined unless @images[version].image instanceof Image
      @images[version].image.versions.id(@images[version].id)

articleSchema.virtual('url').get -> @urls[0]

Article = module.exports = app.db.model 'Article', articleSchema

getAvailableUrl = (url, callback) ->
  urlPattern = new RegExp("^#{url}")
  Article.find(urls: urlPattern).exec (err, articles) ->
    if err then return errs.handle(err, callback)
    urlPattern = new RegExp("^#{url}(_(\\d+))?$")
    urls = (
      (articleUrl for articleUrl in article.urls \
       when articleUrl.match urlPattern) for article in articles)
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
