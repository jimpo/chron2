describe.skip 'image', ->
  before (done) ->
    server.run(done)

  beforeEach(refreshDatabase)

  describe 'index', ->
    it 'should have a listing of images', ->
    it 'should have a images sorted by date', ->
    it 'should have edit links for each image', ->
    describe 'when image is deleted', ->
      it 'should remove image document', ->
      it 'should remove delete image original from S3', ->
      it 'should remove image row from page', ->
  describe 'upload', ->
    it 'should have a file chooser', ->
    describe 'when image is selected from file system', ->
      it 'should show image', ->
      it 'should have upload link',
      it 'should have cancel link',
      describe 'when image is uploaded', ->
        it 'should create a new image document', ->
        it 'should upload the original to S3', ->
