api = require './index'


exports.init = (server) ->
  server.get('/image', api.image.index)
