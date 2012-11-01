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
  describe.skip 'upload', ->
    it 'should have a file chooser', ->
    describe 'when image is selected from file system', ->
      it 'should show image', ->
      it 'should have upload link',
      it 'should have cancel link',
      describe 'when image is uploaded', ->
        it 'should create a new image document', ->
        it 'should upload the original to S3', ->
