errs = require 'errs'
events = require 'events'

initialization = require 'app/initialization'


describe 'mongodb initializer', ->
  before ->
    app.config =
      MONGODB: 'mongo url'
    app._db = app.db

  beforeEach ->
    app.db = new events.EventEmitter
    app.db.open = sinon.stub()

  after ->
    app.db = app._db

  it 'should open connection to Mongo DB', (done) ->
    initialization.mongodb ->
      app.db.open.should.have.been.calledWith('mongo url')
      done()
    app.db.emit('open')

  it 'should call back with an error if error is fired', (done) ->
    initialization.mongodb (err) ->
      err.should.be.an 'Error'
      done()
    app.db.emit('error', errs.create('ConnectionError'))

  it 'should call back successfully if connection is opened', (done) ->
    initialization.mongodb(done)
    app.db.emit('open')
