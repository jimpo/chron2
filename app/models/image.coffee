errs = require 'errs'
mongoose = require 'mongoose'
util = require 'util'

app = require '../../app'


imageSchema = new mongoose.Schema
  caption: String
  date: {type: Date, default: Date.now}
  location: String
  photographer: String
  url: {type: String, required: true, unique: true}

imageSchema.methods.generateUrl = (filename) ->
  @url = util.randomString(8) + '-' + filename

Image = module.exports = app.db.model 'Image', imageSchema
