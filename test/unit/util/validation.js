'use strict';

var Validation = require('util/validation');


describe('Validation', function () {
    describe('constructor', function () {
        it('should use given error message', function () {
            var validation = new Validation('target', 'Error message');
            validation.message.should.equal('Error message');
        });

        it('should set default error message if there is none', function () {
            var validation = new Validation('target');
            expect(validation.message).to.exist;
        });

        it('should validate existence if no validator is given', function () {
            var validation = new Validation('target');
            validation.validator().should.be.false;
            validation.validator(false).should.be.true;
        });
    });

    describe('#check()', function () {
        it('should run validation function', function () {
            var validator = sinon.spy();
            var validation = new Validation('target', 'error', validator);
            validation.check();
            validator.should.have.been.called;
        });

        it('should pass target to validation function', function () {
            var validator = sinon.spy();
            var validation = new Validation('target', 'error', validator);
            validation.check();
            validator.should.have.been.calledWith('target');
        });

        it('should return undefined if validator succeeds', function () {
            var validation = new Validation(
                'target', 'Error message', function () { return true; });
            expect(validation.check()).not.to.exist;
        });

        it('should return undefined if validator succeeds', function () {
            var validation = new Validation(
                'target', 'Error message', function () { return true; });
            expect(validation.check()).not.to.exist;
        });

        it('should return error message if validator fails', function () {
            var validation = new Validation(
                'target', 'Error message', function () { return false; });
            validation.check().should.equal('Error message');
        });
    });
});
