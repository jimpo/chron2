errs = require 'errs'
fs = require 'fs'
path = require 'path'


module.exports = (callback) ->
  fs.readFile path.join(__dirname, '../../config.json'), (err, data) ->
    if err then return errs.handle(err, callback)
    try
      callback(null, JSON.parse(data.toString()))
    catch err
      errs.handle(err, callback)
