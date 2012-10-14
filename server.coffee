express = require 'express'
mongoose = require 'mongoose'

app = require './app'
helpers = require './app/helpers'
User = require './app/models/user'


server = express()
running = false


sessionUser = (req, res, next) ->
  res.locals.user = req.session.user and
    new User({username: req.session.user})
  next()

server.configure 'development', 'test', ->
  server.use(express.static(__dirname + '/public'))

server.configure 'production', ->
  oneYear = 365.25 * 24 * 60 * 60;
  app.use express.static(__dirname + '/public', {maxAge: oneYear})

server.configure ->
  server.use express.bodyParser()
  server.use express.methodOverride()
  server.use express.cookieParser('secret')
  server.use express.session()
  server.use express.csrf()
  server.use express.compress()
  server.use sessionUser

exports.run = (callback) ->
  if running then return callback()
  app.configure (err) ->
    if err then return callback(err)
    app.init (err) ->
      if err then return callback(err)
      configureVirtualHosts(
        'www': app.controllers.site.route
      )
      server.listen(app.config.PORT)
      app.log.notice "Site configured and listening on port #{app.config.PORT}
 in #{server.settings.env} mode"
      running = true
      callback()

createVirtualServer = (route) ->
  virtualServer = express()
  virtualServer.set 'views', __dirname + '/views'
  virtualServer.set 'view engine', 'jade'
  virtualServer.locals helpers
  route.init(virtualServer)
  virtualServer.use (err, req, res, next) ->
    app.log.error(err)
    errOptions = {showStack: true} if process.env.NODE_ENV is not 'production'
    express.errorHandler(errOptions)(err, req, res, next)
  virtualServer

configureVirtualHosts = (hosts) ->
  for subdomain, route of hosts
    domain = "#{subdomain}.#{app.config.DOMAIN_NAME}"
    server.use express.vhost(domain, createVirtualServer(route))

if require.main is module
  exports.run (err) ->
    err and console.error(err)
