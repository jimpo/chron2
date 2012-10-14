mongoose = require 'mongoose'

app = require '../../app'


articleSchema = new mongoose.Schema
  authors: [String]
  body: {type: String, required: true}
  created: {type: Date, default: Date.now, required: true}
  updated: {type: Date, default: Date.now, required: true}
  taxonomy: {type: [String], required: true}
  subtitle: String
  teaser: String
  title: {type: String, required: true}
  urls: {type: [String], required: true}

articleSchema.pre('save', (next) ->
  this.updated = new Date
)

articleSchema.methods.addUrlForTitle = (callback) ->
  getAvailableUrl(URLify(@title), 0, (err, url) =>
    if err then return errs.handle(err, callback)
    @urls.unshift(url)
    callback()
  )

Article = module.exports = app.db.model 'Article', articleSchema

getAvailableUrl = (url, n, callback) ->
  newUrl = if n > 0 then url + '-' + n else url
  Article.find {urls: newUrl}, (err, stuff) ->
    console.log(stuff)
    callback()

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