app = require '..'


exports.init = (callback) =>
  app.db.on('error', callback)
  app.db.once('open', () -> callback(null, app.db))
