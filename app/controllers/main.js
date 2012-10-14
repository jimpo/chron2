'use strict';

var User = require('../models/user');


exports.home = function (req, res, next) {
    if (req.session.user) {
        User.findOne({username: req.session.user},
                     function (err, user) {
                         if (err) return next(err);
                         res.render('home', {
                             user: user,
                         });
                     });
    }
    else {
        res.render('home');
    }
};

exports.login = function (req, res, next) {
    res.render('login', {
        username: undefined,
        errors: undefined,
        token: req.session._csrf,
    });
};

exports.loginData = function (req, res, next) {
    checkUserPassword(
        req.body.user, req.body.passwd, function (err, retryErrors) {
            if (err) next(err);
            else if (retryErrors) {
                res.render('login', {
                    username: req.body.user,
                    errors: retryErrors,
                    token: req.session._csrf,
                });
            }
            else {
                req.session.user = req.body.user;
                res.redirect(req.query.redirect || '/');
            }
        });
};

exports.logout = function (req, res, next) {
    delete req.session.user;
    res.redirect('/');
};

function checkUserPassword(username, password, callback) {
    if (!username) {
        return callback(null, {
            username: {message: 'Please enter username'},
        });
    }
    if (!password) {
        return callback(null, {
            passwd: {message: 'Please enter password'},
        });
    }

    User.findOne({username: username}, 'passwd_hash', function (err, user) {
        if (err) {
            errs.handle(err, callback);
        }
        else if (!user) {
            callback(null, {
                username: {message: 'User "' + username + '" does not exist'},
            });
        }
        else {
            user.matchesPassword(password, function (err, match) {
                if (err) {
                    callback(err);
                }
                else if (!match) {
                    callback(null, {
                        passwd: {message: 'Password did not match'},
                    });
                }
                else {
                    callback();
                }
            });
        }
    });
};
