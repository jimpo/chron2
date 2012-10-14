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
