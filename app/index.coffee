mongoose = require 'mongoose'

config = require '../config'

# Reuire all files in the same dir as this one
# put them on the exports object

requireAll = (dir) ->
  path = require("path")
  require("fs").readdirSync __dirname, (err, files) ->
    files.forEach (file) ->
      exports[file] = require(path.join(__dirname, file.replace(/\.coffee$/, ""))) if file.match(/\.coffee$/)

requireAll "./models"

@db = mongoose.createConnection(config.db)

exports.init = (callback) =>
  @db.on('error', callback)
  @db.once('open', callback)