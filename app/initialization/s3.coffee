errs = require 'errs'
knox = require 'knox'

app = require '..'


class S3Client extends knox

  handleResponse: (res, callback) ->
    data = ''
    res.on('data', (chunk) -> data += chunk)
    res.on('end', ->
      err = undefined
      switch res.statusCode
        when 200 then err = undefined
        when 204 then err = undefined
        when 403 then err = 'Forbidden'
        else err = 'Unknown error'

      if err?
        callback(errs.create 'S3Error'
          message: err
          status: res.statusCode
          body: data
        )
      else
        callback(undefined, data)
    )
    res.on('close', callback)

module.exports = (callback) ->
  client = new S3Client(app.config.S3)
  callback(null, client)
