_ = require 'underscore'
async = require 'async'
errs = require 'errs'

app = require '../..'
Image = require '../../models/image'

IMAGES_PER_PAGE = 20


exports.upload = (req, res, next) ->
  res.render 'admin/image/upload'

exports.handleUpload = (req, res, next) ->
  async.map req.files.files, uploadImage, (err, response) ->
    if err then return next(err)
    res.json response

exports.index = (req, res, next) ->
  limit = req.query.limit ? IMAGES_PER_PAGE
  Image.find().limit(limit).sort(date: 'desc').exec (err, images) ->
    res.render 'admin/image'
      images: images

exports.edit = (req, res, next) ->
  urlPattern = new RegExp("^#{req.params.name}\.")
  Image.findOne {url: urlPattern}, (err, image) ->
    if err then return next(err)
    else if not image?
      next()
    else
      res.render 'admin/image/edit'
        doc: image
        errors: null
        messages: req.flash('info')
        imageTypes: Image.IMAGE_TYPES

exports.update = (req, res, next) ->
  urlPattern = new RegExp("^#{req.params.name}\.")
  Image.findOne {url: urlPattern}, (err, image) ->
    if err then return next(err)
    else if not image?
      next()
    else
      flash = (message) ->
        app.log.info(message)
        req.flash('info', message)
      updateImage(image, req.body.doc, flash, (err, retryErrors) ->
        if err then return next(err)
        else if retryErrors
          res.render 'admin/image/edit'
            doc: image
            errors: retryErrors
            messages: req.flash('info')
            imageTypes: Image.IMAGE_TYPES
        else
          res.redirect "/image/#{image.name}/edit"
      )

exports.createVersion = (req, res, next) ->
  urlPattern = new RegExp("^#{req.params.name}\.")
  Image.findOne {url: urlPattern}, (err, image) ->
    if err then return next(err)
    else if not image?
      next()
    else
      image.versions.push(type: req.body.type)
      version = _.last(image.versions)
      image.generateUrlForVersion(
        version, req.body.x1, req.body.x1, image.url)
      image.validate (err) ->
        if err and err.name is 'ValidationError'
          res.send(406, err)
        else if err
          errs.handle(err, callback)
        else
          image.uploadImageVersion(version, req.body, (err) ->
            if err then return next(err)
            image.save (err) ->
              if err then return errs.handle(err, callback)
              app.log.info "Image version \"#{version.url}\" was created"
              res.send version
          )

updateImage = (image, doc, flash, callback) ->
  image.set(doc)
  image.validate (err) ->
    if err and err.name is 'ValidationError'
      callback(null, err.errors)
    else if err
      errs.handle(err, callback)
    else
      image.save (err) ->
        if err then return errs.handle(err, callback)
        flash("Image \"#{image.url}\" was updated")
        callback(err)

uploadImage = (fileInfo, callback) ->
  image = new Image
  image.generateUrl(fileInfo.filename)
  image.upload fileInfo, (err) ->
    if err then return errs.handle(err, callback)
    image.save (err) ->
      response =
        name: image.url
        size: fileInfo.size
        url: "\/image/#{image.url}/edit"
        delete_url: "\/image/#{image.url}"
        delete_type: 'DELETE'
      callback(err, response)
