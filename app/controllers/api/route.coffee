api = require './index'
app = require '../..'


exports.init = (server) ->
  server.get('/image', api.image.index)
