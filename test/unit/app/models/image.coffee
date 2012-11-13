_ = require 'underscore'
fs = require 'fs'
im = require 'imagemagick'
nock = require 'nock'
path = require 'path'

Image = require 'app/models/image'
s3 = require 'app/initialization/s3'


describe 'Image', ->
  image = version = null

  before (done) ->
    app.configure (err) ->
      return done(err) if err?
      s3 (err, client) ->
        app.s3 = client
        done(err)

  beforeEach ->
    image = new Image(
      name: 'abcdefgh-raichu'
      mimeType: 'image/png'
      caption: 'What? Pikachu is evolving'
      location: 'Vermillion City'
      photographer: 'Misty'
    )
    dim =
        x1: 1
        y1: 2
        x2: 3
        y2: 4
    image.versions.push(type: 'LargeRect', dim: dim)
    version = image.versions[0]

  describe 'filename', ->
    it 'should set name and mimeType', ->
      delete image.name
      delete image.mimeType
      image.filename = 'raichu.png'
      expect(image.name).to.exist
      expect(image.mimeType).to.exist

    it 'should set name to a random character sequence followed by filename', ->
      image.filename = 'raichu.png'
      image.name.should.match /^[a-zA-Z0-9]+\-raichu$/

    it 'should be the image name with the appropriate extension', ->
      image.filename.should.equal 'abcdefgh-raichu.png'

  describe 'mimeType', ->
    it 'should be "image/gif" for .gif images', ->
      image.filename = 'raichu.gif'
      image.mimeType.should.equal 'image/gif'

    it 'should be "image/png" for .png images', ->
      image.filename = 'raichu.png'
      image.mimeType.should.equal 'image/png'

    it 'should be "image/jpeg" for .jpg images', ->
      image.filename = 'raichu.jpg'
      image.mimeType.should.equal 'image/jpeg'

    it 'should be "image/jpeg" for .jpeg images', ->
      image.filename = 'raichu.jpeg'
      image.mimeType.should.equal 'image/jpeg'

    it 'should be invalid for non-image mimeTypes', (done) ->
      image.filename = 'raichu.txt'
      image.validate (err) ->
        expect(err).to.exist
        err.errors.should.have.property 'mimeType'
        done()

    it 'should be case insensitive', ->
      image.filename = 'raichu.JPG'
      image.mimeType.should.equal 'image/jpeg'

  describe 'url', ->
    it 'should be the S3 path for this image', ->
      image.url.should.equal "/images/abcdefgh-raichu.png"

  describe '#upload()', ->
    fileInfo =
      mime: 'image/jpeg'
      length: 8012
      path: '/tmp/image_path'

    beforeEach ->
      image.name = 'raichu'
      sinon.stub(app.s3, 'putFile')

    afterEach ->
      app.s3.putFile.restore()

    it 'should putFile to s3 with appropriate request headers', (done) ->
      headers =
        'Content-Type': 'image/jpeg'
        'Content-Length': 8012
        'Cache-Control': 'public,max-age=' + 365.25 * 24 * 60 * 60
      app.s3.putFile.yields()
      image.upload fileInfo, (err) ->
        app.s3.putFile.should.have.been.calledWith(
          '/tmp/image_path', '/images/raichu.png')
        done(err)

  describe '#download()', ->
    it 'should fetch file from s3', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com')
        .get('/images/abcdefgh-raichu.png')
        .reply(403)
      image.download (err, data) ->
        scope.done()
        done()

    it 'should call back with an error if there\'s an error', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com')
        .get('/images/abcdefgh-raichu.png')
        .reply(403)
      image.download (err, data) ->
        err.should.be.an.instanceOf Error
        err.constructor.name.should.equal 'S3Error'
        err.message.should.equal 'Forbidden'
        done()

    it 'should callback with binary buffer of file contents', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com')
        .get('/images/abcdefgh-raichu.png')
        .reply(200, 'pikachu image')
      image.name = 'abcdefgh-raichu'
      image.download (err, data) ->
        data.should.equal 'pikachu image'
        done(err)

  describe '#removeImage()', ->
    it 'should remove image original from S3', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com:443')
        .delete('/images/abcdefgh-raichu.png')
        .reply(200)
      image.removeImage (err) ->
        scope.done()
        done(err)

  describe 'versions', ->
    it 'should create a new image version on push', ->
      image.versions[0].type.should.equal 'LargeRect'

    it 'should make model valid', (done) ->
      image.validate(done)

    it 'should be invalid if version not is not known', (done) ->
      version.type = 'Not a version'
      image.validate (err) ->
        expect(err).to.exist
        done()

    describe '#url()', ->
      it 'should be the dimensions prepended to the image filename', ->
        url = '/images/versions/636x393-1-2-3-4-abcdefgh-raichu.png'
        version.url().should.equal url

    describe '#fullUrl()', ->
      it 'should be the cloudfront cdn with the version url', ->
        url = '/images/versions/636x393-1-2-3-4-abcdefgh-raichu.png'
        version.fullUrl().should.equal ('http://cdn.example.com' + url)

    describe '#upload()', ->
      beforeEach ->
        sinon.stub(image, 'download').yields(null, 'original image')
        sinon.stub(image, 'crop').yields(null, 'cropped image')

      afterEach ->
        image.download.restore()
        image.crop.restore()

      it 'should download original image', (done) ->
        version.upload (err) ->
          image.download.should.have.been.called
          done()

      it 'should crop original image', (done) ->
        version.upload (err) ->
          image.crop.should.have.been.calledWith(version, 'original image')
          done()

      it 'should put cropped image buffer in s3', (done) ->
        url = '/images/versions/636x393-1-2-3-4-abcdefgh-raichu.png'
        scope = nock('https://s3_bucket.s3.amazonaws.com')
          .put(url, 'cropped image')
          .reply(200)
        version.upload (err) ->
          return done(err) if err?
          scope.done()
          done(err)

    describe '#removeImage()', ->
      it 'should remove image version from S3', (done) ->
        scope = nock('https://s3_bucket.s3.amazonaws.com:443')
          .delete('/images/versions/636x393-1-2-3-4-abcdefgh-raichu.png')
          .reply(200)
        version.removeImage (err) ->
          scope.done()
          done(err)

  describe '#crop()', ->
    version = null
    dimensions =
      x1: 20
      y1: 30
      x2: 720
      y2: 462
    tmpdir = path.join(__dirname, '../../../../tmp')
    buffer = null

    beforeEach (done) ->
      app.log = {warning: console.log}
      image.name = 'original'
      image.mimeType = 'image/jpeg'
      version = image.versions.create(type: 'LargeRect', dim: dimensions)
      fs.readFile(path.join(__dirname, '../../../pikachu.png'), 'binary',
        (err, data) ->
          buffer = data
          done(err)
      )

    it 'should write original image to local /tmp directory', (done) ->
      spy = sinon.spy(fs, 'writeFile')
      image.crop(version, buffer, (err, cropped) ->
        fs.writeFile.restore()
        spy.should.have.been.called
        path.dirname(spy.firstCall.args[0]).should.equal tmpdir
        spy.firstCall.args[1].should.equal buffer
        spy.firstCall.args[2].should.equal 'binary'
        done()
      )

    it 'should crop the image with imagemagick', (done) ->
      fsSpy = sinon.spy(fs, 'writeFile')
      imSpy = sinon.spy(im, 'convert')
      image.crop(version, buffer, (err, cropped) ->
        fs.writeFile.restore()
        im.convert.restore()
        src = fsSpy.firstCall.args[0]
        imSpy.should.have.been.called
        args = imSpy.firstCall.args[0]
        dest = _.last(args)

        path.dirname(dest).should.equal tmpdir
        args.should.deep.equal [
          '-crop', '700x432+20+30', '-resize', '636x393', src, dest]
        done(err)
      )

    it 'should yield the cropped image buffer', (done) ->
      fsSpy = sinon.stub(fs, 'readFile').yields(null, 'cropped')
      imSpy = sinon.spy(im, 'convert')
      image.crop(version, buffer, (err, cropped) ->
        im.convert.restore()
        fs.readFile.restore()
        dest = _.last(imSpy.firstCall.args[0])
        fsSpy.should.have.been.calledWith(dest, 'binary')
        cropped.should.equal 'cropped'
        done(err)
      )

    it 'should remove images written to disk', (done) ->
      fsSpy = sinon.spy(fs, 'unlink')
      imSpy = sinon.spy(im, 'convert')
      image.crop(version, buffer, (err, cropped) ->
        im.convert.restore()
        fs.unlink.restore()
        src = imSpy.firstCall.args[0][4]
        dest = imSpy.firstCall.args[0][5]
        fsSpy.should.have.been.calledWith(src)
        fsSpy.should.have.been.calledWith(dest)
        done(err)
      )

  describe '#removeVersion()', (done) ->
    beforeEach (done) ->
      sinon.stub(image, 'save').yields()
      sinon.stub(version, 'removeImage').yields()
      image.removeVersion(version._id, done)

    afterEach ->
      image.save.restore()
      version.removeImage.restore()

    it 'should yield an error if version does not exist', ->
      image.removeVersion 5, (err) ->
        err.should.be.an('Error')
        err.message.should.match /Version does not exist/

    it 'should remove version document from image', ->
      image.versions.should.have.length 0

    it 'should save image to database', ->
      image.save.should.have.been.called

    it 'should remove image version from S3', ->
      version.removeImage.should.have.been.called

  describe '#remove()', (done) ->
    beforeEach (done) ->
      sinon.stub(image.collection, 'remove').yields()
      sinon.stub(image, 'removeImage').yields()
      sinon.stub(version, 'removeImage').yields()
      image.remove(done)

    afterEach ->
      image.collection.remove.restore()
      image.removeImage.restore()
      version.removeImage.restore()

    it 'should remove image original from S3', ->
      image.removeImage.should.have.been.called

    it 'should remove all image versions from S3', ->
      version.removeImage.should.have.been.called
