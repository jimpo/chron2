_ = require 'underscore'
errs = require 'errs'
mongoose = require 'mongoose'

app = require '../../app'
Author = require './author'


articleSchema = new mongoose.Schema
  authors: {type: [Author], required: true}
  body: {type: String, required: true}
  created: {type: Date, default: Date.now, required: true}
  subtitle: String
  taxonomy: {type: [String], required: true}
  teaser: String
  title: {type: String, required: true}
  updated: {type: Date, default: Date.now, required: true}
  urls: {type: [{type: String, match: /[a-z_\d\-]/}], required: true}

articleSchema.pre('save', (next) ->
  this.updated = new Date
  next()
)

articleSchema.methods.addUrlForTitle = (callback) ->
  getAvailableUrl(URLify(@title), (err, url) =>
    if err then return errs.handle(err, callback)
    @urls.unshift(url)
    callback()
  )

Article = module.exports = app.db.model 'Article', articleSchema

getAvailableUrl = (url, callback) ->
  urlPattern = new RegExp("^#{url}(_(\\d+))?$")
  Article.where('url', url).exec (err, articles) ->
    if err then return errs.handle(err, callback)
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
    max_chars = 100  if not max_chars?
    removelist = ["a", "an", "as", "at", "before", "but", "by", "for", "from", "is", "in", "into", "like", "of", "off", "on", "onto", "per", "since", "than", "the", "this", "that", "to", "up", "via", "with"]
    r = new RegExp("\\b(" + removelist.join("|") + ")\\b", "gi")
    s = s.replace(r, "")
    s = s.replace(/[^-\w\s]/g, "") # remove unneeded chars
    s = s.replace(/^\s+|\s+$/g, "") # trim leading/trailing spaces
    s = s.replace(/[-\s]+/g, "-") # convert spaces to hyphens
    s = s.toLowerCase() # convert to lowercase
    s.substring 0, maxChars # trim to first num_chars chars
