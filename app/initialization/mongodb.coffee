app = require '..'


module.exports = (callback) =>
  app.db.open(app.config.MONGODB)
  app.db.on('error', callback)
  app.db.once('open', () -> callback(null, app.db))
