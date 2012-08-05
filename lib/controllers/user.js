'use strict'

var _ = require('underscore');

var models = require('../models');


exports.new = function (req, res, next) {
    res.render('users/new', {
        locals: {
            doc: {},
            errors: null,
        }
    });
};

exports.create = function (req, res, next) {
    createUser(req.body.doc, req.body.passwd, req.body.passwd_confirm,
               function (err, retry_err) {
                   if (err) next(err);
                   else if (retry_err) {
                       res.render('users/new', {
                           locals: {
                               doc: req.body.doc,
                               errors: retry_err,
                           }
                       });
                   }
                   else {
                       res.redirect('/');
                   }
               });
};

function createUser(doc, passwd, passwd_confirm, callback) {
    if (passwd != passwd_confirm) {
        return callback(null, ['Confirmation password does not match. Enter ' +
                        'password again.']);
    }

    var user = new models.User(doc);
    user.setPassword(passwd, function (err) {
        if (err) return callback(err);
        user.save(function (err) {
            if (_.isArray(err)) callback(null, err);
            else callback(err);
        });
    });
};
