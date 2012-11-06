errs = require 'errs'

Staff = require '../../models/staff'


exports.new = (req, res, next) ->
  res.render 'admin/staff/new'
    doc: {}
    errors: null
    token: req.session._csrf

exports.create = (req, res, next) ->
  createAuthor req.body.doc, (err, retryErrors) ->
    if err then return next(err)
    else if retryErrors
      res.render 'admin/staff/new'
        doc: req.body.doc
        errors: retryErrors
        token: req.session._csrf
    else
      res.redirect '/'

createStaff = (doc, callback) ->
  staff = new Staff(doc)
  staff.validate (err) ->
    if err and err.name is 'ValidationError'
      callback(null, err.errors)
    else if err
      errs.handle(err, callback)
    else
      author.save (err) ->
        callback(err)
