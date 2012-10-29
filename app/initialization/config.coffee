errs = require 'errs'
fs = require 'fs'
path = require 'path'


module.exports = (callback) ->
  env = process.env.NODE_ENV ? 'development'
  filepath = path.join(__dirname, "../../config.#{env}.json")
  fs.readFile filepath, 'utf8', (err, data) ->
    if err then return errs.handle(err, callback)
    try
      callback(null, JSON.parse(data.toString()))
    catch err
      errs.handle(err, callback)
