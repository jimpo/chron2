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
      console.log(article.taxonomy)
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
    it 'should add new url to front of article urls', (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, [])
      article.addUrlForTitle (err) ->
        mongoose.Query.prototype.exec.restore()
        article.urls.should.have.length 2
        article.urls[1].should.equal 'ash-winning'
        done(err)

    it 'new url should be lowercased', (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, [])
      article.addUrlForTitle (err) ->
        mongoose.Query.prototype.exec.restore()
        article.urls[0].should.match /[a-z_\d\-]+/
        done(err)

    it 'new url should contain key words of title', (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, [])
      article.addUrlForTitle (err) ->
        mongoose.Query.prototype.exec.restore()
        newUrl = article.urls[0]
        newUrl.should.contain 'ash'
        newUrl.should.contain 'defeats'
        newUrl.should.contain 'gary'
        newUrl.should.contain 'indigo'
        newUrl.should.contain 'plateau'
        done(err)

    it 'new url should not have unnecessary words', (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, [])
      article.addUrlForTitle (err) ->
        mongoose.Query.prototype.exec.restore()
        newUrl = article.urls[0]
        newUrl.should.not.contain '-in-'
        done(err)

    it 'should not use existing url', (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec')
        .yields(null, [new Article(urls: 'ash-defeats-gary-indigo-plateau')])
      article.addUrlForTitle (err) ->
        mongoose.Query.prototype.exec.restore()
        article.urls[0].should.not.equal 'ash-defeats-gary-indigo-plateau'
        done(err)

    it 'should use next available numerical url', (done) ->
      article.title = 'Pokemon'
      sinon.stub(mongoose.Query.prototype, 'exec')
        .yields(null, [
          new Article(urls: ['pokemon', 'pokemon_2'])
          new Article(urls: ['pokemon_1', 'digimon'])
        ])
      article.addUrlForTitle (err) ->
        mongoose.Query.prototype.exec.restore()
        article.urls[0].should.equal 'pokemon_3'
        done(err)
