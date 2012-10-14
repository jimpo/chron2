var controllers = require('./controllers');


exports.init = function (app) {
    app.get('/', controllers.main.home);
    app.get('/login', controllers.main.login);
    app.post('/login', controllers.main.loginData);
    app.get('/logout', controllers.main.logout);

    app.get('/users/new', controllers.user.new);
    app.post('/users', controllers.user.create);
};
