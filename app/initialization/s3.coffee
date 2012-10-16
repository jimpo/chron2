knox = require 'knox'

app = require '..'


module.exports = (callback) ->
  bucket = if process.env.NODE_ENV is 'build' then 'static' else 'file'
  client = knox.createClient
    key: app.config.S3.key
    secret: app.config.S3.secret
    bucket: app.config.S3.buckets[bucket]
  callback(null, client)
