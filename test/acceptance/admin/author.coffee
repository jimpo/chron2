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
          author = Author.prototype.save.thisValues[0]
          Author.prototype.save.restore()
          author.name.should.equal 'Ash Ketchum'
          author.affiliation.should.equal 'PokeTrainer'
          author.biography.should.equal 'The best Pokemon trainer ever.'
          author.tagline.should.equal 'Wanna be the very best'
          author.twitter.should.equal '@pokefan'
          author.currentColumnist.should.be.false
          done()

    it 'should redirect to admin index page after author is created', (done) ->
      sinon.stub(Author.prototype, 'save').yields()
      browser
        .fill('Name', 'Ash Ketchum')
        .pressButton 'Submit', () ->
          Author.prototype.save.restore()
          browser.redirected.should.be.true;
          browser.location.pathname.should.equal('/')
          done()

    it 'should not create article when model is invalid', (done) ->
      sinon.stub(Author.prototype, 'save').yields()
      browser
        .pressButton 'Submit', () ->
          Author.prototype.save.should.not.have.been.called
          Author.prototype.save.restore()
          done()

    it 'should display errors when model is invalid', (done) ->
      browser
        .pressButton 'Submit', ->
          errors = browser.text('.alert-error')
          expect(errors).to.exist
          errors.should.contain 'Validator "required" failed for path name'
          nameInput = browser.query('form input#name')
          nameControlGroup = nameInput.parentNode.parentNode
          nameControlGroup.getAttribute('class').should.contain 'error'
          done()

    it 'should fill fields with values when model is invalid', (done) ->
      browser
        .fill('Tagline', 'Wanna be the very best')
        .check('#currentColumnist')
        .pressButton 'Submit', ->
          form = browser.query('form')
          expect(form).to.exist
          form.querySelector('input#tagline').value
            .should.equal('Wanna be the very best')
          form.querySelector('input#currentColumnist').checked.should.be.true
          done()
