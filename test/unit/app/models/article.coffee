mongoose = require 'mongoose'

Article = require 'app/models/article'


describe 'Article', ->
  article = null

  before ->
    app.config ?= {}
    app.config.TAXONOMY = [
      name: 'News'
      children: []
    ]

  beforeEach ->
    article = new Article(
      authors: []
      title: 'Ash defeats Gary in Indigo Plateau'
      subtitle: 'Oak arrives just in time'
      teaser: 'Ash becomes new Pokemon champion'
      body: '**Pikachu** wrecks everyone. The End.'
      taxonomy: ['News']
      urls: ['ash-winning']
    )

  describe 'constructor', ->
    it 'should be valid', (done) ->
      article.validate(done)

    it 'should be invalid without a body', (done) ->
      article.body = ''
      article.validate (err) ->
        expect(err).to.exist
        done()

    it 'should be invalid without a taxonomy', (done) ->
      article.taxonomy = []
      article.validate (err) ->
        expect(err).to.exist
        done()

  describe 'url', ->
    it 'should be the first element of urls', ->
      article.urls = ['charmander', 'bulbasaur', 'squirtle']
      article.url.should.equal 'charmander'

  describe '#addUrlForTitle()', ->
    beforeEach (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, [
        new Article(urls: ['pokemon', 'pokemon_2'])
        new Article(urls: ['pokemon_1', 'digimon'])
      ])
      article.addUrlForTitle(done)

    afterEach ->
      mongoose.Query.prototype.exec.restore()

    it 'should add new url to front of article urls', ->
      article.urls.should.have.length 2
      article.urls[1].should.equal 'ash-winning'

    it 'new url should be lowercased', ->
      article.url.should.match /[a-z_\d\-]+/

    it 'new url should contain key words of title', ->
      article.url.should.contain 'ash'
      article.url.should.contain 'defeats'
      article.url.should.contain 'gary'
      article.url.should.contain 'indigo'
      article.url.should.contain 'plateau'

    it 'new url should not have unnecessary words', ->
      article.url.should.not.contain '-in-'

    it 'new url should be at most 100 characters', (done) ->
      article.title = 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz
abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz'
      article.addUrlForTitle (err) ->
        article.url.length.should.not.be.above 100
        done(err)

    it 'new url should not end with a dash', (done) ->
      article.title = 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz
abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstu-vwxyz'
      article.addUrlForTitle (err) ->
        article.url.should.not.match /\-$/
        done(err)

    it 'should not use existing url', (done) ->
      article.title = 'Pokemon'
      article.addUrlForTitle (err) ->
        article.url.should.not.equal 'pokemon'
        done(err)

    it.skip 'should use next available numerical url', (done) ->
      article.title = 'Pokemon'
      article.addUrlForTitle (err) ->
        article.url.should.equal 'pokemon_3'
        done(err)
