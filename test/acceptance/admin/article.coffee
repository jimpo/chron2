util = require 'util'

Article = require 'app/models/article'
Author = require 'app/models/author'

SUCCESS_CODE = 200


describe 'article', ->
  before (done) ->
    server.run(done)

  describe '/article/new', ->
    browser = null

    beforeEach (done) ->
      url = fullUrl('admin', '/article/new')
      Browser.visit url, {runScripts: false}, (err, _browser) ->
        browser = _browser
        done(err)

    it 'should successfully load page', ->
      browser.statusCode.should.equal SUCCESS_CODE

    it 'should have form posting to /article', ->
      form = browser.query('form')
      expect(form).to.exist
      form.getAttribute('method').should.equal 'POST'
      form.getAttribute('action').should.equal '/article'

    it 'should create a new article when form is submitted', (done) ->
      sinon.stub(Article.prototype, 'save').yields()
      browser
        .fill('Title', 'Ash defeats Gary in Indigo Plateau')
        .fill('Subtitle', 'Oak arrives just in time')
        .fill('Teaser', 'Ash becomes new Pokemon Champion')
        .fill('Body', '**Pikachu** wrecks everyone. The End.')
        .select('Section', 'News')
        .pressButton('Submit', () ->
          Article.prototype.save.should.have.been.called
          article = Article.prototype.save.thisValues[0]
          article.title.should.equal('Ash defeats Gary in Indigo Plateau')
          article.subtitle.should.equal('Oak arrives just in time')
          article.teaser.should.equal('Ash becomes new Pokemon Champion')
          article.body.should.equal('**Pikachu** wrecks everyone. The End.')
          article.taxonomy[0].should.equal 'News'
          article.taxonomy.should.have.length 1
          article.authors.should.have.length 0

          Article.prototype.save.restore()
          done()
        )

    it 'should redirect to admin index page with flash message after article is
 created', (done) ->
      sinon.stub(Article.prototype, 'save').yields()
      browser
        .fill('Title', 'Ash defeats Gary in Indigo Plateau')
        .fill('Subtitle', 'Oak arrives just in time')
        .fill('Teaser', 'Ash becomes new Pokemon Champion')
        .fill('Body', '**Pikachu** wrecks everyone. The End.')
        .select('Section', 'News')
        .pressButton 'Submit', () ->
          Article.prototype.save.restore()
          browser.redirected.should.be.true
          browser.location.pathname.should.equal('/')
          flash = browser.text('.alert-info')
          expect(flash).to.exist
          flash.should.contain 'Article "Ash defeats Gary in Indigo Plateau" was
 created'
          browser.location.pathname.should.equal('/')
          done()

    it 'should not create article when model is invalid', (done) ->
      sinon.stub(Article.prototype, 'save').yields()
      browser
        .fill('Subtitle', 'Oak arrives just in time')
        .pressButton 'Submit', () ->
          Article.prototype.save.should.not.have.been.called
          Article.prototype.save.restore()
          done()

    it 'should display errors when model is invalid', (done) ->
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

    it 'should fill fields with values when model is invalid', (done) ->
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

    it 'should look up authors by name', (done) ->
      author = new Author(name: 'Brock')
      sinon.stub(Author, 'findOne').yields(author)
      browser
        .fill('Authors', 'Brock')
        .pressButton 'Submit', ->
          Author.findOne.should.have.been.calledWith {name: 'Brock'}
          Author.findOne.restore()
          done()

    it 'should use id of queried authors', (done) ->
      author = new Author(name: 'Brock')
      sinon.stub(Author, 'findOne').yields(null, author)
      sinon.stub(Article.prototype, 'save').yields()
      browser
        .fill('Title', 'Ash defeats Gary in Indigo Plateau')
        .fill('Body', '**Pikachu** wrecks everyone. The End.')
        .fill('Authors', 'Brock')
        .select('Section', 'News')
        .pressButton 'Submit', ->
          Article.prototype.save.should.have.been.called
          article = Article.prototype.save.thisValues[0]
          Article.prototype.save.restore()
          Author.findOne.restore()

          article.authors.should.have.length 1
          article.authors[0].should.equal author._id
          done()

    it 'should create new author if none found', (done) ->
      sinon.stub(Author, 'findOne').yields()
      sinon.stub(Author.prototype, 'save').yields()
      browser
        .fill('Authors', 'Brock')
        .pressButton 'Submit', ->
          Author.prototype.save.should.have.been.called
          author = Author.prototype.save.thisValues[0]
          Author.prototype.save.restore()
          Author.findOne.restore()
          author.name.should.equal 'Brock'
          done()

    it 'should flash that new author was created', (done) ->
      sinon.stub(Author, 'findOne').yields()
      sinon.stub(Author.prototype, 'save').yields()
      browser
        .fill('Title', 'Ash defeats Gary in Indigo Plateau')
        .fill('Body', '**Pikachu** wrecks everyone. The End.')
        .fill('Authors', 'Brock')
        .select('Section', 'News')
        .pressButton 'Submit', ->
          Author.prototype.save.restore()
          Author.findOne.restore()
          flash = browser.text('.alert-info')
          flash.should.contain 'Author "Brock" was created'
          done()
