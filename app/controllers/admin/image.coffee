async = require 'async'
errs = require 'errs'

Image = require '../../models/image'


exports.upload = (req, res, next) ->
  res.render 'admin/image/upload'
    token: req.session._csrf

exports.handleUpload = (req, res, next) ->
  async.map req.files, uploadImage, (err) ->
    if err then return next(err)
  res.json []

uploadImage = (fileInfo, callback) ->
  image = new Image
  image.generateUrl(fileInfo.name)
  app.s3.putFile fileInfo.path, image.url, (err, res) ->
    callback(err, image)