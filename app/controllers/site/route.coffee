site = require './index'


exports.init = (server) ->
  server.get('/', site.main.home)
  server.get('/login', site.main.login)
  server.post('/login', site.main.loginData)
  server.get('/logout', site.main.logout)

  server.get('/users/new', site.user.new)
  server.post('/users', site.user.create)
