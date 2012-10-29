Author = require 'app/models/author'


describe 'author', ->
  before (done) ->
    server.run(done)

  beforeEach(refreshDatabase)

  describe 'creation', ->
    browser = null

    beforeEach (done) ->
      Browser.visit fullUrl('admin', '/author/new'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should have form posting to /author', ->
      form = browser.query('form')
      expect(form).to.exist
      form.getAttribute('method').should.equal 'POST'
      form.getAttribute('action').should.equal '/author'

    describe 'when author is invalid', ->
      it 'should not create new author', (done) ->
        Author.count (err, initial) ->
          return done(err) if err?
          browser.pressButton 'Submit', ->
            Author.count (err, final) ->
              final.should.equal initial
              done(err)

      it 'should display errors', (done) ->
        browser
          .pressButton 'Submit', ->
            errors = browser.text('.alert-error')
            expect(errors).to.exist
            errors.should.contain 'Validator "required" failed for path name'
            nameInput = browser.query('form input#name')
            nameControlGroup = nameInput.parentNode.parentNode
            nameControlGroup.getAttribute('class').should.contain 'error'
            done()

      it 'should fill fields with entered values', (done) ->
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

    describe 'when author is valid', ->
      initial = null

      beforeEach (done) ->
        Author.count (err, count) ->
          return done(err) if err?
          initial = count
          browser
            .fill('Name', 'Ash Ketchum')
            .fill('Affiliation', 'PokeTrainer')
            .fill('Biography', 'The best Pokemon trainer ever.')
            .fill('Tagline', 'Wanna be the very best')
            .fill('Twitter', '@pokefan')
            .pressButton('Submit', done)

      it 'should create a new author when form is submitted', (done) ->
        Author.count (err, final) ->
          final.should.equal (initial + 1)
          done(err)

      it 'should make an author with given values', (done) ->
        Author.findOne {name: 'Ash Ketchum'}, (err, author) ->
          expect(author).to.exist
          author.name.should.equal 'Ash Ketchum'
          author.affiliation.should.equal 'PokeTrainer'
          author.biography.should.equal 'The best Pokemon trainer ever.'
          author.tagline.should.equal 'Wanna be the very best'
          author.twitter.should.equal '@pokefan'
          author.currentColumnist.should.be.false
          done(err)

      it 'should redirect to admin index page after author is created', ->
        browser.redirected.should.be.true;
        browser.location.pathname.should.equal('/')

      it 'should flash an author creation message', ->
        flash = browser.text('.alert-info')
        flash.should.contain(
          'Author "Ash Ketchum" was saved')