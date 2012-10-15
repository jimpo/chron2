Author = require 'app/models/author'


describe 'author', ->
  before (done) ->
    server.run(done)

  # TODO: Write tests for /staff. Need to run scripts in zombie.

  describe '/author/new', ->
    browser = null

    beforeEach (done) ->
      url = fullUrl('admin', '/author/new')
      Browser.visit url, {runScripts: false}, (err, _browser) ->
        browser = _browser
        done(err)

    it 'should have form posting to /author', ->
      form = browser.query('form')
      expect(form).to.exist
      form.getAttribute('method').should.equal 'POST'
      form.getAttribute('action').should.equal '/author'

    it 'should create a new author when form is submitted', (done) ->
      sinon.stub(Author.prototype, 'save').yields()
      browser
        .fill('Name', 'Ash Ketchum')
        .fill('Affiliation', 'PokeTrainer')
        .fill('Biography', 'The best Pokemon trainer ever.')
        .fill('Tagline', 'Wanna be the very best')
        .fill('Twitter', '@pokefan')
        .pressButton 'Submit', () ->
          Author.prototype.save.should.have.been.called
          Author.prototype.save.restore()
          author = Author.prototype.save.thisValues[0]
          author.name.should.equal 'Ash Ketchum'
          author.affiliation.should.equal 'Ash Ketchum'
          author.biography.should.equal 'The best Pokemon trainer ever.'
          author.tagline.should.equal 'Wanna be the very best'
          author.twitter.should.equal '@pokefan'
          author.currentColumnist.should.be.false
          done()
