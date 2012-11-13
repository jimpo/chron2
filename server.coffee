express = require 'express'
flash = require 'connect-flash'
mongoose = require 'mongoose'
stylus = require 'stylus'

require './lib/errors'  # register custom error types by requiring it
require './lib/util'    # extends util globally by requiring it

app = require './app'
helpers = require './app/helpers'
User = require './app/models/user'


server = express()
running = false


dynamicLocals = (req, res, next) ->
  res.locals.user = req.session.user and
    new User({username: req.session.user})
  res.locals.token = req.session._csrf
  next()

flashLog = (req, res, next) ->
  req.flash = do (flash=req.flash) ->
    (type, msg) ->
      app.log.log(type, msg) if msg?
      flash.call(this, type, msg)
  next()

server.configure 'development', 'test', ->
  server.use(stylus.middleware
    src: 'app/assets'
    dest: 'public'
    force: true
    compile: (str, path) ->
      stylus(str)
        .set('filename', path)
        .set('compress', true)
        .set('include css', true)
  )
  server.use(express.static(__dirname + '/public'))
  server.use(express.static(__dirname + '/app/assets'))

server.configure 'production', ->
  oneYear = 365.25 * 24 * 60 * 60;
  app.use express.static(__dirname + '/public', {maxAge: oneYear})

server.configure ->
  server.use express.bodyParser(uploadDir: __dirname + '/tmp')
  server.use express.methodOverride()
  server.use express.cookieParser('secret')
  server.use express.session()
  server.use express.csrf()
  server.use express.compress()
  server.use flash()
  server.use flashLog
  server.use dynamicLocals

exports.run = (callback) ->
  if running then return callback()
  app.configure (err) ->
    if err then return callback(err)
    app.init (err) ->
      if err then return callback(err)
      configureVirtualHosts(
        www: app.controllers.site.route
        admin: app.controllers.admin.route
      )
      server.listen(app.config.PORT)
      app.log.notice "Site configured and listening on port #{app.config.PORT}
 in #{server.settings.env} mode"
      running = true
      callback()

createVirtualServer = (route) ->
  virtualServer = express()
  virtualServer.set 'views', __dirname + '/app/views'
  virtualServer.set 'view engine', 'jade'
  virtualServer.locals helpers
  virtualServer.locals
    staticCdn: ''
    useCompiledStaticFiles: false
    isProduction: process.env.NODE_ENV is 'production'
  route.init(virtualServer)

  virtualServer.configure 'production', ->
    virtualServer.use (err, req, res, next) ->
      app.log.error(err)
      express.errorHandler()(err, req, res, next)
  virtualServer.configure 'development', ->
    virtualServer.use (err, req, res, next) ->
      app.log.error(err)
      express.errorHandler(showStack: true)(err, req, res, next)

configureVirtualHosts = (hosts) ->
  for subdomain, route of hosts
    domain = "#{subdomain}.#{app.config.DOMAIN_NAME}"
    server.use express.vhost(domain, createVirtualServer(route))

if require.main is module
  exports.run (err) ->
    err and console.error(err)
