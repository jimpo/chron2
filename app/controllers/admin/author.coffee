errs = require 'errs'

Author = require '../../models/author'


exports.new = (req, res, next) ->
  res.render 'admin/author/new'
    doc: {}
    errors: null

exports.create = (req, res, next) ->
  flash = (message) ->
    req.flash('info', message)
  createAuthor req.body.doc, flash, (err, retryErrors) ->
    if err then return next(err)
    else if retryErrors
      res.render 'admin/author/new'
        doc: req.body.doc
        errors: retryErrors
    else
      res.redirect '/'

createAuthor = (doc, flash, callback) ->
  author = new Author(doc)
  author.save (err) ->
    if err and err.name is 'ValidationError'
      callback(null, err.errors)
    else if err
      errs.handle(err, callback)
    else
      flash?("Author \"#{author.name}\" was saved")
      callback()
