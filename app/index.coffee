_ = require 'underscore'
async = require 'async'
errs = require 'errs'
mongoose = require 'mongoose'

initialization = require './initialization'

# Must go before require './models'
exports.db = mongoose.createConnection()

exports.models = require './models'
exports.controllers = require './controllers'



exports.configure = (callback) ->
  initialization.config (err, config) ->
    if err then return errs.handle(err, callback)
    exports.config = config
    callback()

exports.init = (callback) ->
  initializers =
    db: initialization.mongodb
    log: initialization.logger
    s3: initialization.s3
  async.parallel initializers, (err, connections) ->
    if err then return errs.handle(err, callback)
    _.extend(exports, connections)
    callback()
