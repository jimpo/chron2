fs = require 'fs'
path = require 'path'

util = require 'lib/util'

describe 'util', ->
  it 'should extend core util module', ->
    require('util').should.equal(util)

  describe '#requireAll()', ->
    it 'should extend the given object with all modules in a directory', ->
      exports = {}
      util.requireAll(path.join(__dirname, '../../../lib'), exports)
      exports.util.should.equal util

    it 'should not add the index.coffee module', ->
      sinon.stub(fs, 'readdirSync').returns(['util.coffee', 'index.coffee'])
      exports = {}
      util.requireAll(path.join(__dirname, '../../../lib'), exports)
      exports.should.not.have.property 'index'
      fs.readdirSync.restore()

  describe '#randomString()', ->
    it 'should return a string of length n', ->
      for i in [0...30]
        util.randomString(i).should.have.length i

    it 'should return a string with lowercase and uppercase letters, and
 numbers', ->
      util.randomString(40).should.match /^[a-zA-Z0-9]+$/
      util.randomString(40).should.match /[a-z]/
      util.randomString(40).should.match /[A-Z]/
      util.randomString(40).should.match /[0-9]/

    it.skip 'should have a uniform distribution'
