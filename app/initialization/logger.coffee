winston = require 'winston'
Loggly = require('winston-loggly').Loggly

app = require '..'


module.exports = (callback) ->
  logger = new winston.Logger
  logger.setLevels(winston.config.syslog.levels);
  logger.add(winston.transports.Console,
    level: 'debug'
    handleExceptions: process.env.NODE_ENV isnt 'test'
  )

  if app.config.LOGGLY_SUBDOMAIN? and app.config.LOGGLY_TOKEN?
    logger.add(Loggly,
      subdomain: app.config.LOGGLY_SUBDOMAIN
      inputToken: app.config.LOGGLY_TOKEN
      level: 'warning'
      json: true
      handleExceptions: true
    )

  logger.on 'error', (err) ->
    console.error "Logging error: #{JSON.stringify(err)}"

  logger.info 'Logger is up'
  callback(null, logger)
