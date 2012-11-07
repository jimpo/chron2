_ = require 'underscore'
async = require 'async'
errs = require 'errs'

app = require '../..'
Image = require '../../models/image'

IMAGES_PER_PAGE = 20


exports.upload = (req, res, next) ->
  res.render 'admin/image/upload'

exports.handleUpload = (req, res, next) ->
  async.map req.files.files, createImage, (err, response) ->
    if err then return next(err)
    res.json response

exports.index = (req, res, next) ->
  limit = req.query.limit ? IMAGES_PER_PAGE
  Image.find().limit(limit).sort(date: 'desc').exec (err, images) ->
    res.render 'admin/image'
      images: images
      messages: req.flash('info')

exports.edit = (req, res, next) ->
  Image.findOne {name: req.params.name}, (err, image) ->
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
  Image.findOne {name: req.params.name}, (err, image) ->
    if err then return next(err)
    else if not image?
      next()
    else
      flash = (message) ->
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
  Image.findOne {name: req.params.name}, (err, image) ->
    if err then return next(err)
    else if not image?
      next()
    else
      dim = _.pick(req.body, 'x1', 'y1', 'x2', 'y2')
      image.versions.push(type: req.body.type, dim: dim)
      version = _.last(image.versions)
      image.validate (err) ->
        if err and err.name is 'ValidationError'
          res.send(406, err)
        else if err
          errs.handle(err, callback)
        else
          version.upload (err) ->
            return errs.handle(err, next) if err?
            image.save (err) ->
              return errs.handle(err, next) if err?
              req.flash(
                'info', "Image version \"#{version.name()}\" was created")
              res.redirect "/image/#{image.name}/edit"

exports.destroy = (req, res, next) ->
  Image.findOne {name: req.params.name}, (err, image) ->
    if err then return next(err)
    else if not image?
      res.send(404)
    else
      image.remove (err) ->
        return next(err) if err?
        req.flash('info', "Image \"#{image.name}\" was deleted")
        res.send(200)

exports.destroyVersion = (req, res, next) ->
  Image.findOne {name: req.params.name}, (err, image) ->
    if err then return next(err)
    else if not image?
      res.send(404)
    else
      version = image.versions.id(req.params.version)
      return res.send(404) if not version?
      name = version.name()
      image.removeVersion req.params.version, (err) ->
        return errs.handle(err, next) if err?
        req.flash('info', "Image version \"#{name}\" was deleted")
        res.redirect "/image/#{image.name}/edit"

updateImage = (image, doc, flash, callback) ->
  image.set(doc)
  image.validate (err) ->
    if err and err.name is 'ValidationError'
      callback(null, err.errors)
    else if err
      errs.handle(err, callback)
    else
      image.save (err) ->
        return errs.handle(err, callback) if err?
        flash("Image \"#{image.name}\" was updated")
        callback(err)

createImage = (fileInfo, callback) ->
  image = new Image(filename: fileInfo.filename)
  image.upload fileInfo, (err) ->
    if err then return errs.handle(err, callback)
    image.save (err) ->
      response =
        name: image.name
        size: fileInfo.size
        url: "\/image/#{image.url}/edit"
        delete_url: "\/image/#{image.name}"
        delete_type: 'DELETE'
      callback(err, response)
