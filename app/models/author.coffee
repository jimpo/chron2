errs = require 'errs'
mongoose = require 'mongoose'

app = require '../../app'


authorSchema = new mongoose.Schema
  affiliation: String
  biography: String
  currentColumnist: {type: Boolean, default: false}
  name: {type: String, required: true}
  tagline: String
  twitter: String

Author = module.exports = app.db.model 'Author', authorSchema
