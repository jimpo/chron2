mongoose = require 'mongoose'

config = require '../config'


@db = mongoose.createConnection(config.db)

exports.init = (callback) =>
  @db.on('error', callback)
  @db.once('open', callback)
