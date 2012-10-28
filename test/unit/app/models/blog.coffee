mongoose = require 'mongoose'

Blog = require 'app/models/blog'

describe 'Blog', ->
  blog = null

  before ->
    app.config ?= {}
    app.config.TAXONOMY = [
      name: 'Blogs'
      children: []
    ]

  beforeEach ->
    blog = new Blog(
      authors: []
      blog: 'PokeBlog'
      title: 'Ash defeats Gary in Indigo Plateau'
      subtitle: 'Oak arrives just in time'
      teaser: 'Ash becomes new Pokemon champion'
      body: '**Pikachu** wrecks everyone. The End.'
      tags: ['News']
      urls: ['ash-winning']
    )

  describe 'constructor', ->
    it 'should be valid', (done) ->
      blog.validate(done)

    it 'should be invalid without a title', (done) ->
      blog.title = ''
      blog.validate (err) ->
        expect(err).to.exist
        done()

    it 'should be invalid without a body', (done) ->
      blog.body = ''
      blog.validate (err) ->
        expect(err).to.exist
        done()

    it 'should be invalid without tags', (done) ->
      blog.tags = []
      blog.validate (err) ->
        expect(err).to.exist
        done()

    it 'should be invalid without a blog', (done) ->
      blog.blog = ''
      blog.validate (err) ->
        expect(err).to.exist
        done()


  describe 'url', ->
    it 'should be the first element of urls', ->
      blog.urls = ['charmander', 'bulbasaur', 'squirtle']
      blog.url.should.equal 'charmander'

  describe '#addUrlForTitle()', ->
    beforeEach (done) ->
      sinon.stub(mongoose.Query.prototype, 'exec').yields(null, [
        new Blog(urls: ['pokemon', 'pokemon_2'])
        new Blog(urls: ['pokemon_1', 'digimon'])
      ])
      blog.addUrlForTitle(done)

    afterEach ->
      mongoose.Query.prototype.exec.restore()

    it 'should add new url to front of blog urls', (done) ->
      blog.urls.should.have.length 2
      blog.urls[1].should.equal 'ash-winning'
      done()

    it 'new url should be lowercased', (done) ->
      blog.url.should.match /[a-z_\d\-]+/
      done()

    it 'new url should contain key words of title', (done) ->
      blog.url.should.contain 'ash'
      blog.url.should.contain 'defeats'
      blog.url.should.contain 'gary'
      blog.url.should.contain 'indigo'
      blog.url.should.contain 'plateau'
      done()

    it 'new url should not have unnecessary words', (done) ->
      blog.url.should.not.contain '-in-'
      done()

    it 'should not use existing url', (done) ->
      blog.title = 'Pokemon'
      blog.addUrlForTitle (err) ->
        blog.url.should.not.equal 'pokemon'
        done(err)

    it 'should use next available numerical url', (done) ->
      blog.title = 'Pokemon'
      blog.addUrlForTitle (err) ->
        blog.url.should.equal 'pokemon_3'
        done(err)
