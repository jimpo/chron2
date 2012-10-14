_ = require 'underscore'
async = require 'async'
errs = require 'errs'
mongoose = require 'mongoose'

config = require '../config'
initialization = require './initialization'


# Reuire all files in the same dir as this one
# put them on the exports object

requireAll = (dir) ->
  path = require("path")
  require("fs").readdirSync __dirname, (err, files) ->
    files.forEach (file) ->
      exports[file] = require(path.join(__dirname, file.replace(/\.coffee$/, ""))) if file.match(/\.coffee$/)

requireAll "./models"


@db = mongoose.createConnection()

exports.configure = (callback) ->
  initialization.config (err, config) ->
    if err then return errs.handle(err, callback)
    exports.config = config
    callback()

exports.init = (callback) ->
  initializers =
    db: initialization.mongodb
    log: initialization.logger
  async.parallel initializers, (err, connections) ->
    if err then return errs.handle(err, callback)
    _.extend(exports, connections)
    callback()
