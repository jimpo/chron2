express = require 'express'
mongoose = require 'mongoose'

app = require './app'
helpers = require './app/helpers'
route = require './app/routes'
User = require './app/models/user'


server = express()
running = false


sessionUser = (req, res, next) ->
  res.locals.user = req.session.user and
    new User({username: req.session.user})
  next()

server.configure ->
  server.set 'views', __dirname + '/views'
  server.set 'view engine', 'jade'
  server.locals helpers
  server.use express.bodyParser()
  server.use express.methodOverride()
  server.use express.cookieParser('secret')
  server.use express.session()
  server.use express.csrf()
  server.use express.static(__dirname + '/public')
  server.use sessionUser
  server.use server.router
  server.use express.errorHandler({showStack: true, dumpExceptions: true})

route.init(server)

exports.run = (callback) ->
  if running then return callback()
  app.configure (err) ->
    if err then return callback(err)
    app.init (err) ->
      if err then return callback(err)
      server.listen(app.config.PORT)
      app.log.notice "Site configured and listening on port #{app.config.PORT}
 in #{server.settings.env} mode"
      running = true
      callback()

if require.main is module
  exports.run (err) ->
    err and console.error(err)
