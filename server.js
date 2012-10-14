require('coffee-script');
var express = require('express');
var mongoose = require('mongoose');

var app = require('./app');
var config = require('./config');
var helpers = require('./lib/helpers');
var route = require('./lib/route');
var User = require('./lib/models/user');


var server = express();
var running = false;


function sessionUser(req, res, next) {
    res.locals.user = req.session.user &&
        new User({username: req.session.user});
    next();
}

server.configure(function () {
    server.set('views', __dirname + '/views');
    server.set('view engine', 'jade');
    server.locals(helpers);
    server.use(express.bodyParser());
    server.use(express.methodOverride());
    server.use(express.cookieParser('secret'));
    server.use(express.session());
    server.use(express.csrf());
    server.use(express.static(__dirname + '/public'));
    server.use(sessionUser);
    server.use(server.router);
    server.use(express.errorHandler({showStack: true, dumpExceptions: true}));
});

route.init(server);

exports.run = function (callback) {
    if (running) {
        return callback()
    }
    app.init(function (err) {
        if (err) console.error(err);
        console.log('Server is listening on port ' + config.port);
        server.listen(config.port);
        running = true;
        callback();
    });
};

if (require.main === module) {
    exports.run(function (err) {
        err && console.error(err);
    });
}
