async = require 'async'
errs = require 'errs'

app = require '../..'
Image = require '../../models/image'


exports.upload = (req, res, next) ->
  res.render 'admin/image/upload'
    token: req.session._csrf

exports.handleUpload = (req, res, next) ->
  async.map req.files.files, uploadImage, (err, response) ->
    if err then return next(err)
    res.json response

uploadImage = (fileInfo, callback) ->
  image = new Image
  image.generateUrl(fileInfo.filename)
  headers =
    'Content-Type': fileInfo.mime
    'Content-Length': fileInfo.length
    'Cache-Control': 'public,max-age=' + 365.25 * 24 * 60 * 60
  app.s3.putFile(fileInfo.path, "/images/#{image.url}", headers, (err, res) ->
    if err then return errs.handle(err, callback)
    image.save (err) ->
      response =
        name: image.url
        size: fileInfo.size
        url: "\/image/#{image.url}/edit"
        delete_url: "\/image/#{image.url}"
        delete_type: 'DELETE'
      callback(err, response)
  )
