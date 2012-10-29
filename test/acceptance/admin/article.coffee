_ = require 'underscore'
util = require 'util'

Article = require 'app/models/article'
Author = require 'app/models/author'

SUCCESS_CODE = 200


describe 'article', ->
  before (done) ->
    server.run(done)

  beforeEach(refreshDatabase)

  describe 'creation', ->
    browser = null

    beforeEach (done) ->
      Browser.visit fullUrl('admin', '/article/new'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should successfully load page', ->
      browser.statusCode.should.equal SUCCESS_CODE

    it 'should have form posting to /article', ->
      form = browser.query('form')
      expect(form).to.exist
      form.getAttribute('method').should.equal 'POST'
      form.getAttribute('action').should.equal '/article'

    describe 'when article is invalid', ->
      it 'should not create article', (done) ->
        Article.count (err, initial) ->
          return done(err) if err?
          browser
            .fill('Subtitle', 'Oak arrives just in time')
            .pressButton 'Submit', ->
              Article.count (err, final) ->
                final.should.equal initial
                done(err)

      it 'should display errors', (done) ->
        browser
          .fill('Subtitle', 'Oak arrives just in time')
          .pressButton 'Submit', ->
            errors = browser.text('.alert-error')
            expect(errors).to.exist
            errors.should.contain 'Validator "required" failed for path title'
            titleInput = browser.query('form input#title')
            titleControlGroup = titleInput.parentNode.parentNode
            titleControlGroup.getAttribute('class').should.contain 'error'
            done()

      it 'should fill fields with entered values', (done) ->
        browser
          .fill('Subtitle', 'Oak arrives just in time')
          .fill('Teaser', 'Ash becomes new Pokemon Champion')
          .pressButton 'Submit', ->
            form = browser.query('form')
            expect(form).to.exist
            form.querySelector('input#subtitle').value
              .should.equal 'Oak arrives just in time'
            form.querySelector('textarea#teaser').value
              .should.equal 'Ash becomes new Pokemon Champion'
            done()

    describe 'when article is valid', ->
      initial = null

      beforeEach (done) ->
        Article.count (err, count) ->
          return done(err) if err?
          initial = count
          browser
            .fill('Title', 'Ash defeats Gary in Indigo Plateau')
            .fill('Subtitle', 'Oak arrives just in time')
            .fill('Teaser', 'Ash becomes new Pokemon Champion')
            .fill('Body', '**Pikachu** wrecks everyone. The End.')
            .select('Section', 'News')
            .pressButton('Submit', done)

      it 'should create a new article', (done) ->
        Article.count (err, final) ->
          final.should.equal (initial + 1)
          done(err)

      it 'should make an article with the filled in fields', (done) ->
        title = 'Ash defeats Gary in Indigo Plateau'
        Article.findOne {title: title}, (err, article) ->
          expect(article).to.exist
          article.subtitle.should.equal 'Oak arrives just in time'
          article.teaser.should.equal 'Ash becomes new Pokemon Champion'
          article.body.should.equal '**Pikachu** wrecks everyone. The End.'
          _.toArray(article.taxonomy).should.eql ['News', 'University'] # TODO: This is wrong #zombieproblems
          article.authors.should.have.length 0
          done(err)

      it 'should redirect to admin index page', ->
        browser.redirected.should.be.true
        browser.location.pathname.should.equal('/')

      it 'should flash an article creation message', ->
        flash = browser.text('.alert-info')
        flash.should.contain(
          'Article "Ash defeats Gary in Indigo Plateau" was saved')

    describe 'when article is filled out with existing author', ->
      author = null

      beforeEach (done) ->
        Author.findOne {name: 'Brock'}, (err, _author) ->
          author = _author
          expect(author).to.exist
          browser
            .fill('Title', 'Ash defeats Gary in Indigo Plateau')
            .fill('Body', '**Pikachu** wrecks everyone. The End.')
            .fill('Authors', 'Brock')
            .select('Section', 'News')
            .pressButton('Submit', done)

      it 'should use id of queried authors', (done) ->
        title = 'Ash defeats Gary in Indigo Plateau'
        Article.findOne {title: title}, (err, article) ->
          expect(article).to.exist
          _.toArray(article.authors).should.eql [author._id]
          done(err)

    describe 'when author doesn\'t exist', ->
      initial = null

      beforeEach (done) ->
        Author.count (err, count) ->
          return done(err) if err?
          initial = count
          browser
            .fill('Title', 'Ash defeats Gary in Indigo Plateau')
            .fill('Body', '**Pikachu** wrecks everyone. The End.')
            .fill('Authors', 'Misty')
            .select('Section', 'News')
            .pressButton('Submit', done)

      it 'should create new author', (done) ->
        Author.count (err, final) ->
          final.should.equal (initial + 1)
          done(err)

      it 'should make author with given name', (done) ->
        Author.findOne {name: 'Misty'}, (err, author) ->
          expect(author).to.exist
          done(err)

      it 'should assign that author to article', (done) ->
        Author.findOne {name: 'Misty'}, (err, author) ->
          return done(err) if err?
          title = 'Ash defeats Gary in Indigo Plateau'
          Article.findOne {title: title}, (err, article) ->
            _.toArray(article.authors).should.eql [author._id]
            done(err)

      it 'should flash that new author was created', ->
        flash = browser.text('.alert-info')
        flash.should.contain 'Author "Misty" was created'
