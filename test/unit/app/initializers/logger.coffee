initialization = require 'app/initialization'


describe 'logger initializer', ->
  before ->
    app.config = {}

  it 'should yield a logger', (done) ->
    initialization.logger (err, logger) ->
      logger.should.respondTo 'log'
      done(err)

  it 'logger should respond to logging levels', (done) ->
    initialization.logger (err, logger) ->
      logger.should.respondTo 'debug'
      logger.should.respondTo 'info'
      logger.should.respondTo 'notice'
      logger.should.respondTo 'warning'
      logger.should.respondTo 'error'
      logger.should.respondTo 'crit'
      logger.should.respondTo 'alert'
      logger.should.respondTo 'emerg'
      done(err)

  it 'logger should have a console transport', (done) ->
    initialization.logger (err, logger) ->
      logger.transports.should.have.property 'console'
      done(err)

  it 'logger should have a loggly transport if loggly config is set', (done) ->
    app.config.LOGGLY_SUBDOMAIN = 'subdomain'
    app.config.LOGGLY_TOKEN = 'token'
    initialization.logger (err, logger) ->
      logger.transports.should.have.property 'loggly'
      done(err)
