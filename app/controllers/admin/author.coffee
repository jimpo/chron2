errs = require 'errs'

Author = require '../../models/author'


exports.new = (req, res, next) ->
  res.render 'admin/author/new'
    doc: {}
    errors: null
    token: req.session._csrf

exports.create = (req, res, next) ->
  createAuthor req.body.doc, (err, retryErrors) ->
    if err then return next(err)
    else if retryErrors
      console.log retryErrors
      res.render 'admin/author/new'
        doc: req.body.doc
        errors: retryErrors
        token: req.session._csrf
    else
      res.redirect '/'

createAuthor = (doc, callback) ->
  author = new Author(doc)
  author.validate (err) ->
    if err and err.name is 'ValidationError'
      callback(null, err.errors)
    else if err
      errs.handle(err, callback)
    else
      author.save (err) ->
        callback(err)
