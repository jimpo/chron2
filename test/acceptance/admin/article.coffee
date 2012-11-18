_ = require 'underscore'
util = require 'util'

Article = require 'app/models/article'
Author = require 'app/models/author'
images = require('test/acceptance/fixtures/images').Image

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

  describe 'update', ->
    article = browser = null

    beforeEach (done) ->
      Article.findOne (urls: 'ash-gets-pikachu-oak'), (err, _article) ->
        return done(err) if err?
        article = _article
        url = fullUrl('admin', "/article/#{article.url}/edit")
        Browser.visit url, (err, _browser) ->
          browser = _browser
          done(err)

    it 'should successfully load page', ->
      browser.statusCode.should.equal SUCCESS_CODE

    it 'should have form putting to /article/:url', ->
      form = browser.query('form')
      expect(form).to.exist
      form.getAttribute('method').should.equal 'POST'
      form.getAttribute('action').should.equal "/article/#{article.url}"
      browser.field('_method').value.should.equal 'put'

    it 'should fill fields with current values', ->
      browser.field('Title').value.should.equal 'Ash Gets Pikachu from Oak'
      browser.field('Body').value.should.equal(
        '**Pikachu** refuses to enter pokeball')
      browser.field('Section').value.should.equal 'News'
      # browser.field('#section1').value.should.be.empty # if zombie worked

    describe 'when article is invalid', ->
      it 'should display errors', (done) ->
        browser
          .fill('Title', '')
          .pressButton 'Submit', ->
            errors = browser.text('.alert-error')
            expect(errors).to.exist
            errors.should.contain 'Validator "required" failed for path title'
            titleInput = browser.query('form input#title')
            titleControlGroup = titleInput.parentNode.parentNode
            titleControlGroup.getAttribute('class').should.contain 'error'
            done()

    describe 'when article is valid', ->
      initial = updatedArticle = null

      beforeEach (done) ->
        Article.count (err, count) ->
          return done(err) if err?
          initial = count
          browser
            .fill('Subtitle', 'Starter Pokemon already taken')
            .fill('Teaser', 'Ash arrived too late')
            .fill('Body', '**Pikachu** wrecks everyone.')
            .select('Section', 'Sports')
            .pressButton 'Submit', (err) ->
              return done(err) if err?
              Article.findOne {urls: article.url}, (err, _article) ->
                updatedArticle = _article
                done(err)

      it 'should not create a new article', (done) ->
        Article.count (err, final) ->
          final.should.equal initial
          done(err)

      it 'should a update an existing article', ->
        expect(updatedArticle).to.exist
        updatedArticle._id.should.eql article._id
        updatedArticle.subtitle.should.equal 'Starter Pokemon already taken'
        updatedArticle.teaser.should.equal 'Ash arrived too late'
        updatedArticle.body.should.equal '**Pikachu** wrecks everyone.'
        _.toArray(updatedArticle.taxonomy).should.eql ['Sports']

      it 'should not modify "created" timestamp', ->
        updatedArticle.created.should.eql article.created

      it 'should modify "updated" timestamp', ->
        updatedArticle.updated.should.be.greaterThan article.updated

      it 'should not modify urls array', ->
        updatedArticle.urls.should.have.length 1

      it 'should redirect to admin index page', ->
        browser.redirected.should.be.true
        browser.location.pathname.should.equal('/')

      it 'should flash an article update message', ->
        flash = browser.text('.alert-info')
        flash.should.contain(
          'Article "Ash Gets Pikachu from Oak" was saved')

    describe 'when article title is changed', ->
      updatedArticle = null

      beforeEach (done) ->
        browser
          .fill('Title', 'Starter Pokemon already taken')
          .pressButton 'Submit', (err) ->
            return done(err) if err?
            Article.findOne {urls: article.url}, (err, _article) ->
              updatedArticle = _article
              done(err)

      it 'should have a new url', ->
        updatedArticle.urls.should.have.length 2
        updatedArticle.url.should.not.equal article.url

    describe 'when new image is selected', ->
      updatedArticle = null

      beforeEach (done) ->
        browser
          .fill('.image-picker[data-version=ThumbRect] .image-id',
            images.charmander._id)
          .fill('.image-picker[data-version=ThumbRect] .version-id',
            images.charmander.versions[0]._id)
          .pressButton 'Submit', (err) ->
            return done(err) if err?
            Article.findOne {urls: article.url}, (err, _article) ->
              updatedArticle = _article
              done(err)

      it 'should add image to model', ->
        updatedArticle.images.ThumbRect.image.should.eql images.charmander._id
        updatedArticle.images.ThumbRect.id.should.eql(
          images.charmander.versions[0]._id)

      it 'should keep old images of different types', ->
        updatedArticle.images.LargeRect.image.should.eql images.squirtle._id
        updatedArticle.images.LargeRect.id.should.eql(
          images.squirtle.versions[0]._id)

  describe 'deletion', ->
    describe 'from from edit page', ->
      browser = initial = null

      beforeEach (done) ->
        Article.count (err, count) ->
          return done(err) if err?
          initial = count
          url = fullUrl('admin', '/article/ash-gets-pikachu-oak/edit')
          Browser.visit url, (err, _browser) ->
            return done(err) if err?
            browser = _browser
            browser.pressButton('Delete', done)

      it 'should remove an article', (done) ->
        Article.count (err, final) ->
          final.should.equal (initial - 1)
          done(err)

      it 'should not find article in database', (done) ->
        Article.findOne {urls: 'ash-gets-pikachu-oak'}, (err, article) ->
          expect(article).not.to.exist
          done(err)

      it 'should redirect to the index page', ->
        browser.location.pathname.should.equal '/article'

      it 'should flash that article was deleted', ->
        flash = browser.text('.alert-info')
        flash.should.contain 'Article "Ash Gets Pikachu from Oak" was deleted'

    describe 'when article is deleted from index page', ->
      browser = initial = null

      beforeEach (done) ->
        Article.count (err, count) ->
          return done(err) if err?
          initial = count
          Browser.visit fullUrl('admin', '/article'), (err, _browser) ->
            return done(err) if err?
            browser = _browser
            browser.clickLink('#ash-gets-pikachu-oak .delete-button', done)

      it 'should remove an article', (done) ->
        Article.count (err, final) ->
          final.should.equal (initial - 1)
          done(err)

      it 'should remove article row from index page', ->
        expect(browser.query('#ash-gets-pikachu-oak')).not.to.exist
