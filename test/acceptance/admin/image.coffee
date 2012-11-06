nock = require 'nock'

Image = require 'app/models/image'


describe 'image', ->
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
      browser.html().should.contain 'squirtle.png'
      browser.html().should.contain 'charmander.png'
      browser.html().should.contain 'bulbasaur.png'

    it 'should have a images sorted by date', ->
      browser.html().should.match /charmander.*squirtle.*bulbasaur/

    it 'should have link images to edit pages', ->
      img = browser.query('tr#A8r9ub3o-squirtle img')
      img.parentNode.href.should.contain '/image/A8r9ub3o-squirtle/edit'

    describe 'when image is deleted', ->
      scope = null

      beforeEach (done) ->
        scope = nock('https://s3_bucket.s3.amazonaws.com:443')
          .delete('/images/A8r9ub3o-squirtle.png')
          .reply(200)
        browser.clickLink('#A8r9ub3o-squirtle .delete-button', done)

      it 'should remove image document', (done) ->
        Image.findOne {name: 'A8r9ub3o-squirtle'}, (err, image) ->
          expect(image).not.to.exist
          done(err)

      it 'should remove images from S3', ->
        scope.done()

      it 'should remove image row from page', ->
        expect(browser.query('#A8r9ub3o-squirtle')).not.to.exist

      it 'should flash that image was deleted', ->
        flash = browser.text('.alert-info')
        flash.should.contain 'Image "A8r9ub3o-squirtle" was deleted'

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
        browser.attach('input[type=file]', 'test/pikachu.jpg', done)

      it 'should show image', ->
        row = browser.query('tr:contains(pikachu.jpg)')
        expect(row).to.exist

      it 'should have upload link', ->
        btn = browser.query('tr:contains(pikachu.jpg) .start button')
        expect(btn).to.exist

      it 'should have cancel link', ->
        btn = browser.query('tr:contains(pikachu.jpg) .cancel button')
        expect(btn).to.exist

      # TODO: figure out how to test this
      describe.skip 'when image is uploaded', ->
        initial = scope = null

        beforeEach (done) ->
          nock.recorder.rec()
          Image.count (err, count) ->
            return done(err) if err?
            initial = count
            browser.pressButton('tr:contains(pikachu.jpg) .start button', done)

        it 'should create a new image document', (done) ->
          Image.count (err, final) ->
            final.should.equal (initial + 1)
            done(err)

        it.skip 'should upload the original to S3', ->

  describe 'update', ->
    browser = image = null

    beforeEach (done) ->
      Image.findOne {name: 'A8r9ub3o-squirtle'}, (err, _image) ->
        return done(err) if err?
        image = _image
        url = fullUrl('admin', '/image/A8r9ub3o-squirtle/edit')
        Browser.visit url, {}, (err, _browser) ->
          browser = _browser
          done(err)

    it 'should fill fields with current values', ->
      browser.field('Caption').value.should.equal 'A water pokemon'
      browser.field('Date').value.should.equal '10/30/2012'

    describe 'when information form is filled out', ->
      updatedImage = null

      beforeEach (done) ->
        browser
          .fill('Caption', 'A turtle pokemon')
          .fill('Location', 'Pallet Town')
          .fill('Photographer', 'Professor Oak')
          .pressButton 'Submit', (err) ->
            return done(err) if err?
            Image.findOne {name: image.name}, (err, _image) ->
              updatedImage = _image
              done(err)

      it 'should updated image information', ->
        updatedImage.date = image.date
        updatedImage.photographer = 'Professor Oak'
        updatedImage.location = 'Pallet Town'
        updatedImage.caption = 'A fire pokemon'

      it 'should stay on edit page', ->
        browser.location.pathname.should.equal '/image/A8r9ub3o-squirtle/edit'

      it 'should flash that image was saved', ->
        flash = browser.text('.alert-info')
        flash.should.contain 'Image "A8r9ub3o-squirtle" was updated'

    describe 'when image delete button is pressed', ->
      initial = scope = null

      beforeEach (done) ->
        Image.count (err, count) ->
          return done(err) if err?
          initial = count
          scope = nock('https://s3_bucket.s3.amazonaws.com:443')
            .delete('/images/A8r9ub3o-squirtle.png')
            .reply(200)
          browser.pressButton('Delete', done)

      it 'should remove an image', (done) ->
        Image.count (err, final) ->
          final.should.equal (initial - 1)
          done(err)

      it 'should not find image in database', (done) ->
        Image.findOne {name: image.name}, (err, article) ->
          expect(article).not.to.exist
          done(err)

      it 'should remove image original from S3', ->
        scope.done()

      it.skip 'should remove all image versions from S3', ->

      it 'should redirect to the index page', ->
        browser.location.pathname.should.equal '/image'
