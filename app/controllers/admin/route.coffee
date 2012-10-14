admin = require './index'


exports.init = (server) ->
  server.get('/', admin.main.index)
  server.get('/article/new', admin.article.new)
  server.post('/article', admin.article.create)
