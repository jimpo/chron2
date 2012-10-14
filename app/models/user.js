'use strict';

var bcrypt = require('bcrypt');
var errs = require('errs');
var mongoose = require('mongoose');
var util = require('util');

var app = require('../../app');


var userSchema = new mongoose.Schema({
    username: {type: String, required: true, unique: true},
    name: {type: String, required: true},
    email: {
        type: String,
        required: true,
        match: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i,
    },
    passwd_hash: {type: String, required: true},
});

userSchema.methods.setPassword = function (passwd, callback) {
    var self = this;
    bcrypt.genSalt(function (err, salt) {
        if (err) return callback(err);
        bcrypt.hash(passwd, salt, function (err, hash) {
            if (err) return callback(err);
            self.passwd_hash = hash;
            callback();
        });
    });
};

userSchema.methods.matchesPassword = function (hash, callback) {
    if (!this.passwd_hash) {
        return callback('User has no password set.');
    }

    bcrypt.compare(hash, this.passwd_hash, callback);
};

module.exports = app.db.model('User', userSchema);
