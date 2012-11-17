_ = require 'underscore'
fs = require 'fs'
nock = require 'nock'
path = require 'path'

images = require('test/acceptance/fixtures/images').Image
Image = require 'app/models/image'


describe 'image', ->
  imageId = images.squirtle._id
  versionId = images.squirtle.versions[0]._id


  before (done) ->
    server.run(done)

  beforeEach(refreshDatabase)

  describe 'index', ->
    browser = null

    beforeEach (done) ->
      Browser.visit fullUrl('admin', '/image'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should have a listing of images', ->
      browser.html().should.contain 'squirtle'
      browser.html().should.contain 'charmander'
      browser.html().should.contain 'bulbasaur'

    it 'should have a images sorted by date', ->
      browser.html().should.match /charmander.*squirtle.*bulbasaur/

    it 'should have link images to edit pages', ->
      id = images.squirtle._id
      img = browser.query("tr##{id} img")
      img.parentNode.href.should.contain "/image/#{id}/edit"

    describe 'when image is deleted', ->
      scope = null

      beforeEach (done) ->
        scope = nock('https://s3_bucket.s3.amazonaws.com:443')
          .delete("/images/#{imageId}.png")
          .reply(204)
          .delete("/images/versions/#{versionId}.png")
          .reply(204)
        browser.clickLink("##{imageId} .delete-button", done)

      it 'should remove image document', (done) ->
        Image.findById imageId, (err, image) ->
          expect(image).not.to.exist
          done(err)

      it 'should remove images from S3', ->
        scope.done()

      it 'should remove image row from page', ->
        expect(browser.query('#' + imageId)).not.to.exist

      it 'should flash that image was deleted', ->
        flash = browser.text('.alert-info')
        flash.should.contain 'Image "squirtle" was deleted'

  describe 'upload', ->
    browser = null

    beforeEach (done) ->
      Browser.visit fullUrl('admin', '/image/upload'), (err, _browser) ->
        browser = _browser
        done(err)

    it 'should have a file chooser', ->
      expect(browser.query('input[type=file]')).to.exist

    describe 'when image is selected from file system', ->
      beforeEach (done) ->
        browser.attach('input[type=file]', 'test/pikachu.png', done)

      it 'should show image', ->
        row = browser.query('tr:contains(pikachu.png)')
        expect(row).to.exist

      it 'should have upload link', ->
        btn = browser.query('tr:contains(pikachu.png) .start button')
        expect(btn).to.exist

      it 'should have cancel link', ->
        btn = browser.query('tr:contains(pikachu.png) .cancel button')
        expect(btn).to.exist

      # TODO: figure out how to test this
      describe.skip 'when image is uploaded', ->
        initial = scope = null

        beforeEach (done) ->
          Image.count (err, count) ->
            return done(err) if err?
            initial = count
            browser.pressButton('tr:contains(pikachu.png) .start button', done)

        it 'should create a new image document', (done) ->
          Image.count (err, final) ->
            final.should.equal (initial + 1)
            done(err)

        it.skip 'should upload the original to S3', ->

  describe 'update', ->
    browser = image = null

    beforeEach (done) ->
      Image.findById imageId, (err, _image) ->
        return done(err) if err?
        image = _image
        url = fullUrl('admin', "/image/#{imageId}/edit")
        Browser.visit url, (err, _browser) ->
          browser = _browser
          done(err)

    it 'should fill fields with current values', ->
      browser.field('Caption').value.should.equal 'A water pokemon'
      browser.field('Date').value.should.equal '10/30/2012'

    it 'should have a list of all versions', ->
      expect(browser.query("#versions ##{versionId}")).to.exist

    describe 'when version is created', ->
      scope = null

      beforeEach (done) ->
        nock('https://s3_bucket.s3.amazonaws.com:443')
          .get("/images/#{imageId}.png")
          .replyWithFile(200, path.join(__dirname, '../../pikachu.png'))
        scope = nock('https://s3_bucket.s3.amazonaws.com:443')
          .filteringPath(
            /\/images\/versions\/\w+\.png/, '/images/versions/VERSIONID.png')
          .filteringRequestBody(-> '*')
          .put('/images/versions/VERSIONID.png', '*')
          .reply(200)
        browser.select '#sizes', 'ThumbRect', (err) ->
          return done(err) if err?
          browser.field('#x1').value = 20
          browser.field('#y1').value = 30
          browser.field('#x2').value = 206
          browser.field('#y2').value = 163
          browser.pressButton('New Version', done)

      it 'should add new version to image document', (done) ->
        Image.findById imageId, (err, image) ->
          image.versions.should.have.length 2
          done(err)

      it 'should create version with correct type and dimensions', (done) ->
        Image.findById imageId, (err, image) ->
          version = image.versions[1]
          version.type.should.equal 'ThumbRect'
          version.dim.x1.should.equal 20
          version.dim.y1.should.equal 30
          version.dim.x2.should.equal 206
          version.dim.y2.should.equal 163
          done(err)

      it 'should upload cropped image to S3', ->
        scope.done()

      it 'should show new version on edit page', ->
        selector = "#versions ##{versionId}"
        expect(browser.query(selector)).to.exist

    describe 'when version is deleted', ->
      scope = null

      beforeEach (done) ->
        scope = nock('https://s3_bucket.s3.amazonaws.com:443')
          .delete("/images/versions/#{versionId}.png")
          .reply(204)
        selector = "#versions ##{versionId} .delete-button"
        browser.clickLink(selector, done)

      it 'should remove version from image document', (done) ->
        Image.findById imageId, (err, image) ->
          image.versions.should.be.empty
          done(err)

      it 'should remove image from S3', ->
        scope.done()

      it 'should remove version from listing', ->
        selector = "#versions ##{versionId} .delete-button"
        expect(browser.query(selector)).not.to.exist

    describe 'when information form is filled out', ->
      updatedImage = null

      beforeEach (done) ->
        browser
          .fill('Caption', 'A turtle pokemon')
          .fill('Location', 'Pallet Town')
          .fill('Photographer', 'Professor Oak')
          .pressButton 'Submit', (err) ->
            return done(err) if err?
            Image.findById imageId, (err, _image) ->
              updatedImage = _image
              done(err)

      it 'should updated image information', ->
        updatedImage.date = image.date
        updatedImage.photographer = 'Professor Oak'
        updatedImage.location = 'Pallet Town'
        updatedImage.caption = 'A fire pokemon'

      it 'should stay on edit page', ->
        browser.location.pathname.should.equal "/image/#{imageId}/edit"

      it 'should flash that image was saved', ->
        flash = browser.text('.alert-info')
        flash.should.contain 'Image "squirtle" was updated'

    describe 'when image delete button is pressed', ->
      initial = scope = null

      beforeEach (done) ->
        Image.count (err, count) ->
          return done(err) if err?
          initial = count
          scope = nock('https://s3_bucket.s3.amazonaws.com:443')
            .delete("/images/#{imageId}.png")
            .reply(204)
            .delete("/images/versions/#{versionId}.png")
            .reply(204)
          browser.pressButton('Delete', done)

      it 'should remove an image', (done) ->
        Image.count (err, final) ->
          final.should.equal (initial - 1)
          done(err)

      it 'should not find image in database', (done) ->
        Image.findOne {name: image.name}, (err, article) ->
          expect(article).not.to.exist
          done(err)

      it 'should remove image original and versions from S3', ->
        scope.done()

      it 'should redirect to the index page', ->
        browser.location.pathname.should.equal '/image'
