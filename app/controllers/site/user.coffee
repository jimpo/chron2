_ = require 'underscore'
errs = require 'errs'

User = require '../../models/user'


exports.new = (req, res, next) ->
  res.render 'site/users/new'
    doc: {}
    errors: null
    token: req.session._csrf

exports.create = (req, res, next) ->
  createUser(req.body.doc, req.body.passwd, req.body.passwd_confirm,
    (err, retryErrors) ->
      if err then next(err)
      else if retryErrors
        res.render 'site/users/new'
          doc: req.body.doc
          errors: retryErrors
          token: req.session._csrf
      else
        req.session.user = req.body.doc.username
        res.redirect '/'
  )

createUser = (doc, passwd, passwdConfirm, callback) ->
  if not passwd
    return callback(null,
      passwd: {message: 'Password is required'},
    )
  if passwd is not passwdConfirm
    return callback(null,
      passwd: {message: 'Passwords do not match. Enter password again.'}
    )

  user = new User(doc)
  user.setPassword passwd, (err) ->
    if err then return errs.handle(err, callback)
    user.validate (err) ->
      if err and err.name is 'ValidationError'
        callback(null, err.errors)
      else if err
        errs.handle(err, callback)
      else
        user.save (err) ->
          if err and err.code is 11000
            return callback(null,
              passwd: {message: "Username \"#{doc.username}\" already exists"}
            )
          callback(err)
