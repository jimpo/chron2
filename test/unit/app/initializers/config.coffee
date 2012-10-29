fs = require 'fs'
path = require 'path'

initialization = require 'app/initialization'


describe 'config', ->
  configFile = path.join(__dirname, '../../../..', 'config.test.json')

  beforeEach ->
    sinon.stub(fs, 'readFile')

  afterEach ->
    fs.readFile.restore()

  it 'should read the config JSON file for the NODE_ENV', (done) ->
    fs.readFile.yields()
    initialization.config (err) ->
      fs.readFile.should.have.been.calledWith(configFile)
      done()

  it 'should yield the parsed JSON object', (done) ->
    data = {arbitrary: 'data'}
    fs.readFile.yields(null, JSON.stringify(data))
    initialization.config (err, config) ->
      config.should.eql data
      done(err)

  it 'should yield error on invalid JSON', (done) ->
    fs.readFile.yields(null, '{invalid JSON')
    initialization.config (err, config) ->
      err.should.be.an('Error')
      done()
