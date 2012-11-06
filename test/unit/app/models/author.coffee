mongoose = require 'mongoose'

Author = require 'app/models/author'


describe 'Author', ->
  author = null

  beforeEach ->
    author = new Author(
      affiliation: 'hogwarts school of witchcraft and wizadry'
      biography: 'survived voldemort as infant'
      currentColumnist: true
      name: 'harry potter'
      positions: [{'seeker', 2011}, {'muggle', 2007}]
      tagline: 'the boy with the scar'
      twitter: 'twitter.com/harrypotter'
      photo: Schema.ObjectId
    )

  describe 'constructor', ->
    it 'should be valid', (done) ->
      author.validate(done)

  describe '#addNewPosition()', ->
    it 'should add new string,date to to front of authors position', (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, []) //need help here
      author.addNewPosition (err) ->
        mongoose.Query.prototype.exec.restore() //need help here
        author.positions.should.have.length 3
        author.urls[2].should.equal {'seeker',2011}
        done(err)

    it 'new position should be string and date', (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, []) //need to change
      autor.addNewPosition (err) ->
        mongoose.Query.prototype.exec.restore()
        article.positions[0][0].should.match /[\d\s]+/
        article.positions[0][1].should.match /[0-9]+/
        done(err)