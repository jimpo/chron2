request = require 'superagent'

SUCCESS_CODE = 200


describe 'image api', ->
  r = res = null

  before (done) ->
    server.run(done)
    r = request.agent()

  beforeEach(refreshDatabase)

  describe 'index', ->
    beforeEach (done) ->
      r.get fullUrl('api', '/image'), (err, _res) ->
        res = _res
        done(err)

    it 'should respond successfully', ->
      console.log res
      res.status.should.equal SUCCESS_CODE

    it 'should respond with valid JSON', ->
      parser = -> JSON.parse res.body
      parser.should.not.throw

    it.skip 'should return specified number of images', ->
    it.skip 'should have image fields populated', ->
    it.skip 'should have all versions as an array', ->
