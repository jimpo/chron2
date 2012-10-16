errs = require 'errs'
mongoose = require 'mongoose'
util = require 'util'

app = require '../../app'


#imageVersion = new mongoose.Schema

imageSchema = new mongoose.Schema
  caption: String
  date: {type: Date, default: Date.now}
  location: String
  photographer: String
  url: {type: String, required: true, unique: true}

imageSchema.methods.generateUrl = (filename) ->
  @url = util.randomString(8) + '-' + filename

imageSchema.virtual('fullUrl').get ->
  "#{app.config.CONTENT_CDN}/images/#{@url}"

imageSchema.virtual('name').get ->
  @url.replace(/\.(gif|jpe?g|png)$/, '')

Image = module.exports = app.db.model 'Image', imageSchema
