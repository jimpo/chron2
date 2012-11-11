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
      r.get fullUrl('api', '/image?limit=2'), (err, _res) ->
        res = _res
        done(err)

    it 'should respond successfully', ->
      res.status.should.equal SUCCESS_CODE

    it 'should respond with a valid JSON array', ->
      res.body.should.be.an('Array')
      res.body.should.not.be.empty

    it 'should return an array with the specified limit', ->
      res.body.should.have.length.below 3

    it 'should return images in sorted order by date', ->
      images = res.body
      images[0].name.should.equal 'bV2CoWu0-charmander'
      images[1].name.should.equal 'A8r9ub3o-squirtle'

    it 'should have images with image fields populated', ->
      squirtle = res.body[1]
      squirtle.should.have.property 'name'
      squirtle.should.have.property 'mimeType'
      squirtle.should.have.property 'caption'
      squirtle.should.have.property 'date'
      squirtle.should.have.property 'versions'

    it 'should have all versions as an array', ->
      squirtle = res.body[1]
      squirtle.versions.should.have.length 1
      version = squirtle.versions[0]
      version.type.should.equal 'LargeRect'
      version.dim.should.eql
          x1: 20
          y1: 30
          x2: 720
          y2: 462
