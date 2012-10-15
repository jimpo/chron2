util = require 'util'

Article = require 'app/models/article'

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
        .fill('Authors', 'Brock')
        .pressButton('Submit', () ->
          Article.prototype.save.should.have.been.called;
          article = Article.prototype.save.thisValues[0];
          article.title.should.equal('Ash defeats Gary in Indigo Plateau')
          article.subtitle.should.equal('Oak arrives just in time')
          article.teaser.should.equal('Ash becomes new Pokemon Champion')
          article.body.should.equal('**Pikachu** wrecks everyone. The End.')
          article.taxonomy[0].should.equal 'News'
          article.taxonomy.should.have.length(1)

          Article.prototype.save.restore()
          done()
        )

    it 'should redirect to admin index page after article is created', (done) ->
      sinon.stub(Article.prototype, 'save').yields()
      browser
        .fill('Title', 'Ash defeats Gary in Indigo Plateau')
        .fill('Subtitle', 'Oak arrives just in time')
        .fill('Teaser', 'Ash becomes new Pokemon Champion')
        .fill('Body', '**Pikachu** wrecks everyone. The End.')
        .select('Section', 'News')
        .fill('Authors', 'Brock')
        .pressButton 'Submit', () ->
          Article.prototype.save.restore()
          browser.redirected.should.be.true;
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
        .pressButton 'Submit', ->
          form = browser.query('form')
          expect(form).to.exist
          form.querySelector('input#subtitle').value
            .should.equal('Oak arrives just in time')
          done()
