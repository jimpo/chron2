errs = require 'errs'

User = require '../../models/user'


exports.home = (req, res, next) ->
  if req.session.user
    User.findOne {username: req.session.user}, (err, user) ->
      if err then return next(err)
      res.render 'home',
        user: user
  else
    res.render 'home'

exports.login = (req, res, next) ->
  res.render 'login',
    username: undefined
    errors: undefined
    token: req.session._csrf

exports.loginData = (req, res, next) ->
  checkUserPassword(req.body.user, req.body.passwd, (err, retryErrors) ->
    if err then next(err)
    else if retryErrors
      res.render 'login',
        username: req.body.user,
        errors: retryErrors,
        token: req.session._csrf,
    else
      req.session.user = req.body.user
      res.redirect(req.query.redirect or '/')
  )

exports.logout = (req, res, next) ->
  delete req.session.user
  res.redirect '/'

checkUserPassword = (username, password, callback) ->
  if not username
    return callback(null,
      username: {message: 'Please enter username'}
    )
  if not password
    return callback(null,
      passwd: {message: 'Please enter password'}
    )

  User.findOne {username: username}, 'passwdHash', (err, user) ->
    if err then errs.handle(err, callback);
    else if not user?
      callback(null,
        username: {message: 'User "' + username + '" does not exist'}
      )
    else
      user.matchesPassword password, (err, match) ->
        if err then errs.handle(err, callback)
        else if not match
          callback(null,
            passwd: {message: 'Password did not match'}
          )
        else
          callback()
