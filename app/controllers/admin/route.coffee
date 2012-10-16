admin = require './index'


exports.init = (server) ->
  server.get('/', admin.main.index)
  server.get('/article/new', admin.article.new)
  server.post('/article', admin.article.create)
  server.get('/article/:url/edit', admin.article.edit)
  server.put('/article/:url', admin.article.update)

  server.get('/author/new', admin.author.new)
  server.post('/author', admin.author.create)
