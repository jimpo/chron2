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

    describe.skip 'when image is deleted', ->
      it 'should remove image document', ->
      it 'should remove delete image original from S3', ->
      it 'should remove image row from page', ->

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
      Image.findOne {url: 'A8r9ub3o-squirtle.png'}, (err, _image) ->
        return done(err) if err?
        image = _image
        url = fullUrl('admin', '/image/A8r9ub3o-squirtle/edit')
        Browser.visit url, (err, _browser) ->
          browser = _browser
          done(err)

    it 'should fill fields with current values', ->
      browser.field('Caption').value.should.equal 'A water pokemon'
      # TODO: Doesn't work. Fucking zombie
      # browser.field('Date').value.should.equal '10/30/12'

    it 'when information form is filled out', ->
      updatedImage = null

      beforeEach (done) ->
        browser
          .fill('Caption', 'A turtle pokemon')
          .fill('Location', 'Pallet Town')
          .fill('Photographer', 'Professor Oak')
          .pressButton 'Submit', (err) ->
            return done(err) if err?
            Image.findOne {url: image.url}, (err, _image) ->
              updatedImage = _image
              done(err)

      it 'should updated image information', ->
        updatedImage.date = image.date
        updatedImage.photographer = 'Professor Oak'
        updatedImage.location = 'Pallet Town'
        updatedImage.caption = 'A fire pokemon'

    describe.skip 'when image delete button is pressed', ->
      initial = null

      beforeEach (done) ->
        Image.count (err, count) ->
          return done(err) if err?
          initial = count
          browser.pressButton('Delete', done)

      it 'should remove an image', (done) ->
        Image.count (err, final) ->
          final.should.equal (initial - 1)
          done(err)

      it 'should not find image in database', (done) ->
        Image.findOne {urls: 'ash-gets-pikachu-oak'}, (err, article) ->
          expect(article).not.to.exist
          done(err)

      it.skip 'should remove image original from S3', ->
      it.skip 'should remove all image versions from S3', ->

      it 'should redirect to the index page', ->
        browser.location.pathname.should.equal '/image'
