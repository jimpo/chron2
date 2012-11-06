admin = require './index'


exports.init = (server) ->
  server.get('/', admin.main.index)
  server.get('/article', admin.article.index)
  server.get('/article/new', admin.article.new)
  server.post('/article', admin.article.create)
  server.get('/article/:url/edit', admin.article.edit)
  server.put('/article/:url', admin.article.update)

  server.get('/staff/new', admin.staff.new)
  server.post('/staff', admin.staff.create)

  server.get('/image', admin.image.index)
  server.get('/image/upload', admin.image.upload)
  server.post('/image/upload', admin.image.handleUpload)
  server.get('/image/:name/edit', admin.image.edit)
  server.put('/image/:name', admin.image.update)
  server.post('/image/:name/version', admin.image.createVersion)
