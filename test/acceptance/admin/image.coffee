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

      describe 'when image is uploaded', ->
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
