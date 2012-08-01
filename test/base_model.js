'use strict'

var should = require('chai').should();

var models = require('../lib/models');


describe('models.BaseModel', function () {
    var pikachu;

    beforeEach(function () {
        pikachu = new models.BaseModel({
            _id: 'pikachu',
            type: 'electric',
            species: 'mouse',
        });
    });

    describe('constructor', function () {
        it('should initialize attributes to constructor argument', function () {
            pikachu.attributes.should.deep.equal({
                _id: 'pikachu',
                type: 'electric',
                species: 'mouse',
            });
        });

        it('should initialize attributes to emtpy object otherwise',
           function () {
               pikachu = new models.BaseModel();
               should.exist(pikachu.attributes);
               pikachu.attributes.should.deep.equal({});
           });
    });

    describe('#get()', function () {
        it('should return attribute if present', function () {
            should.exist(pikachu.get('species'));
            pikachu.get('species').should.equal('mouse');
        });

        it('should return undefined unless present', function () {
            should.not.exist(pikachu.get('fake field'));
        });
    });

    describe('#set()', function () {
        it('should set attributes given an object', function () {
            pikachu.set({
                color: 'yellow',
                location: 'Viridian Forest',
            });
            pikachu.attributes.color.should.equal('yellow');
            pikachu.attributes.location.should.equal('Viridian Forest');
        });

        it('should override old attributes given an object', function () {
            pikachu.set({species: 'cute mouse'});
            pikachu.attributes.species.should.equal('cute mouse');
        });

        it('should keep old attributes', function () {
            pikachu.set({
                color: 'yellow',
                species: 'cute mouse',
            });
            pikachu.attributes.type.should.equal('electric');
        });

        it('should set one attribute given key and value', function () {
            pikachu.set('color', 'yellow');
            pikachu.attributes.color.should.equal('yellow');
        });
    });

    describe('#has()', function () {
        it('should be true if attribute exists', function () {
            pikachu.attributes.trainer = undefined;
            pikachu.has('trainer').should.be.true;
        });

        it('should be false if attribute does not exist', function () {
            pikachu.has('trainer').should.be.false;
        });
    });

    describe('#unset()', function () {
        it('should clear attribute and return false', function () {
            pikachu.unset('species').should.be.true;
            pikachu.attributes.should.not.have.property('species');
        });

        it('should be false on nonexistent attribute', function () {
            pikachu.unset('fake attribute').should.be.false;
        });
    });

    describe('#isNew()', function () {
        it('should be true unless model has rev', function () {
            pikachu.isNew().should.be.true;
        });

        it('should be true unless model has id', function () {
            pikachu = new models.BaseModel({_rev: 'kanto version'});
            pikachu.isNew().should.be.true;
        });

        it('should be false if model has id and rev', function () {
            pikachu.attributes._rev = 'kanto version';
            pikachu.isNew().should.be.false;
        });
    });
});