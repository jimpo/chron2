'use strict';

var errs = require('errs');

var main = require('controllers/main');
var User = require('models').User;


describe('main', function () {
    var req, res, next;

    beforeEach(function () {
        req = {
            session: {
                _csrf: 'csrf token',
            }
        };
        res = {};
        next = {};
    });

    describe('#home()', function () {
        it('should render home view', function () {
            res.render = sinon.spy();
            main.home(req, res, next);
            res.render.should.have.been.calledWith('home', {
                user: undefined,
            });
        });

        it('should pass signed in user to view', function () {
            sinon.stub(User.prototype, 'fetch').yields();
            res.render = sinon.spy();
            req.session = {user: 'pokefan'};
            main.home(req, res, next);
            res.render.should.have.been.calledWith('home');
            var user = res.render.args[0][1].user;
            user.should.be.an.instanceOf(User);
            user.id().should.equal('pokefan');
            User.prototype.fetch.restore();
        });
    });

    describe('#login()', function () {
        it('should render login page', function () {
            res.render = sinon.spy();
            main.login(req, res, next);
            res.render.should.have.been.calledWith('login', {
                user: undefined,
                errors: undefined,
                token: 'csrf token',
            });
        });
    });

    describe('#loginData()', function () {
        var successfulLogin = function (req, res, next, callback) {
            sinon.stub(User.prototype, 'fetch').yields(null);
            sinon.stub(User.prototype, 'matchesPassword').yields(null, true);
            req.body = {
                user: 'pokefan',
                passwd: 'pikapass',
            };
            res.redirect = function (url) {
                User.prototype.fetch.restore();
                User.prototype.matchesPassword.restore();
                callback(url);
            };
            main.loginData(req, res, next);
        };

        it('should fail if username is not provided', function () {
            req.body = {passwd: 'pikapass'};
            res.render = sinon.spy();
            main.loginData(req, res, next);
            res.render.should.have.been.calledWith('login');
            res.render.args[0][1].errors.should.contain(
                'Please enter username');
        });

        it('should fail if password is not provided', function () {
            req.body = {user: 'pokefan'};
            res.render = sinon.spy();
            main.loginData(req, res, next);
            res.render.should.have.been.calledWith('login');
            res.render.args[0][1].errors.should.contain(
                'Please enter password');
        });

        it('should render with user on failure', function () {
            req.body = {user: 'pokefan'};
            res.render = sinon.spy();
            main.loginData(req, res, next);
            res.render.should.have.been.calledWith('login');
            res.render.args[0][1].errors.should.exist;
            res.render.args[0][1].user.should.equal('pokefan');
        });

        it('should fetch given user', function () {
            sinon.stub(User.prototype, 'fetch');
            req.body = {
                user: 'pokefan',
                passwd: 'pikapass',
            };
            main.loginData(req, res, next);
            User.prototype.fetch.should.have.been.called;
            User.prototype.fetch.restore();
        });

        it('should fail if user doesn\'t exist', function () {
            sinon.stub(User.prototype, 'fetch').yields(errs.create({
                status_code: 404,
            }));
            req.body = {
                user: 'pokefan',
                passwd: 'pikapass',
            };
            res.render = sinon.spy();
            main.loginData(req, res, next);
            res.render.should.have.been.calledWith('login');
            res.render.args[0][1].errors.should.contain(
                'User "pokefan" does not exist');
            User.prototype.fetch.restore();
        });

        it('should fail if password is incorrect', function (done) {
            sinon.stub(User.prototype, 'fetch').yields(null);
            sinon.stub(User.prototype, 'matchesPassword').yields(null, false);
            req.body = {
                user: 'pokefan',
                passwd: 'pikapass',
            };
            res.render = function (view, locals) {
                view.should.equal('login');
                locals.errors.should.contain('Password did not match');
                User.prototype.fetch.restore();
                User.prototype.matchesPassword.restore();
                done();
            };
            main.loginData(req, res, next);
        });

        it('should set session user to user id after login', function (done) {
            req.session = {};
            req.query = {};
            successfulLogin(req, res, next, function () {
                req.session.user.should.equal('pokefan');
                done();
            });
        });

        it('should redirect to specified url after login', function (done) {
            req.session = {};
            req.query = {redirect: '/after/path'};
            successfulLogin(req, res, next, function (url) {
                url.should.equal('/after/path');
                done();
            });
        });

        it('should redirect to home page if no redirect given', function (done) {
            req.session = {};
            req.query = {};
            successfulLogin(req, res, next, function (url) {
                url.should.equal('/');
                done();
            });
        });
    });
});
