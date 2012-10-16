admin = require './index'


exports.init = (server) ->
  server.get('/', admin.main.index)
  server.get('/article', admin.article.index)
  server.get('/article/new', admin.article.new)
  server.post('/article', admin.article.create)
  server.get('/article/:url/edit', admin.article.edit)
  server.put('/article/:url', admin.article.update)

  server.get('/author/new', admin.author.new)
  server.post('/author', admin.author.create)

  server.get('/image', admin.image.index)
  server.get('/image/upload', admin.image.upload)
  server.post('/image/upload', admin.image.handleUpload)
  server.get('/image/:url/edit', admin.image.edit)