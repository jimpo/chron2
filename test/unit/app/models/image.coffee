_ = require 'underscore'
fs = require 'fs'
im = require 'imagemagick'
knox = require 'knox'
nock = require 'nock'
path = require 'path'

Image = require 'app/models/image'


describe 'Image', ->
  image = null

  beforeEach ->
    image = new Image(
      filename: 'raichu.png'
      caption: 'What? Pikachu is evolving'
      location: 'Vermillion City'
      photographer: 'Misty'
    )

  describe 'filename', ->
    it 'should set name and mimeType', ->
      expect(image.name).to.exist
      expect(image.mimeType).to.exist

    it 'should not be gettable', ->
      expect(image.filename).not.to.exist

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

  describe 'name', ->
    it 'should consist of a random character sequence followed by filename', ->
      image.name.should.match /^[a-zA-Z0-9]+\-raichu$/

  describe 'url', ->
    it 'should be the image name with an appropriate extension', ->
      image.url.should.equal "#{image.name}.png"

  describe 'versions', ->
    it 'should create a new image version on push', ->
      image.versions.push(type: 'LargeRect', url: 'version_url')
      image.versions[0].type.should.equal 'LargeRect'
      image.versions[0].url.should.equal 'version_url'

    it 'should be invalid if version not is not known', (done) ->
      image.versions.push(type: 'Not a version', url: 'version_url')
      image.validate (err) ->
        expect(err).to.exist
        done()

  describe '#generateUrlForVersion()', ->
    it 'should set url to new url', ->
      image.versions.push(type: 'LargeRect')
      version = image.versions[0]
      url = image.generateUrlForVersion(version, 20, 30)
      expect(url).to.exist
      version.url.should.equal url

    it 'should append the version\'s crop information to the original url', ->
      image.name = 'abcdefgh-raichu'
      image.versions.push(type: 'LargeRect')
      version = image.versions[0]
      image.generateUrlForVersion(version, 20, 30).should.equal(
        '636x393-20-30-abcdefgh-raichu.png')

  describe '#download()', ->
    before ->
      app.s3 = knox.createClient
        key: 's3_key'
        secret: 's3_secret'
        bucket: 's3_bucket'

    it 'should fetch file from s3', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com')
        .get('/images/abcdefgh-raichu.png')
        .reply(403)
      image.name = 'abcdefgh-raichu'
      image.download (err, data) ->
        scope.done()
        done()

    it 'should call back with an error if there\'s an error', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com')
        .get('/images/abcdefgh-raichu.png')
        .reply(403)
      image.name = 'abcdefgh-raichu'
      image.download (err, data) ->
        err.should.be.an('Error')
        done()

    it 'should callback with binary buffer of file contents', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com')
        .get('/images/abcdefgh-raichu.png')
        .reply(200, 'pikachu image')
      image.name = 'abcdefgh-raichu'
      image.download (err, data) ->
        data.should.equal 'pikachu image'
        done(err)

  describe '#cropImage()', ->
    version = null
    dimensions =
      x1: 20
      y1: 30
      w: 700
      h: 432
    tmpdir = path.join(__dirname, '../../../../tmp')
    buffer = null

    beforeEach (done) ->
      app.log = {warning: console.log}
      image.name = 'original'
      image.mimeType = 'image/jpeg'
      image.versions.push(type: 'LargeRect', url: 'version.jpg')
      version = image.versions[0]
      fs.readFile(path.join(__dirname, '../../../pikachu.jpg'), 'binary',
        (err, data) ->
          buffer = data
          done(err)
      )

    it 'should write original image to local /tmp directory', (done) ->
      spy = sinon.spy(fs, 'writeFile')
      image.cropImage(version, dimensions, buffer, (err, cropped) ->
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
      image.cropImage(version, dimensions, buffer, (err, cropped) ->
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
      image.cropImage(version, dimensions, buffer, (err, cropped) ->
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
      image.cropImage(version, dimensions, buffer, (err, cropped) ->
        im.convert.restore()
        fs.unlink.restore()
        src = imSpy.firstCall.args[0][4]
        dest = imSpy.firstCall.args[0][5]
        fsSpy.should.have.been.calledWith(src)
        fsSpy.should.have.been.calledWith(dest)
        done(err)
      )

  describe '#upload()', ->
    fileInfo =
      mime: 'image/jpeg'
      length: 8012
      path: '/tmp/image_path'

    beforeEach ->
      image.name = 'raichu'
      app.s3 =
        putFile: sinon.stub()

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

  describe '#uploadImageVersion()', ->
    version = null
    dimensions =
      x1: 20
      y1: 30
      w: 700
      h: 432

    before ->
      app.s3 = knox.createClient
        key: 's3_key'
        secret: 's3_secret'
        bucket: 's3_bucket'

    beforeEach ->
      image.name = 'original'
      image.versions.push(type: 'LargeRect', url: 'version.png')
      version = image.versions[0]
      sinon.stub(image, 'download').yields(null, 'original image')
      sinon.stub(image, 'cropImage').yields(null, 'cropped image')

    afterEach ->
      image.download.restore()
      image.cropImage.restore()

    it 'should download original image', (done) ->
      image.uploadImageVersion(version, dimensions, (err) ->
        image.download.should.have.been.called
        done()
      )

    it 'should crop original image', (done) ->
      image.uploadImageVersion(version, dimensions, (err) ->
        image.cropImage.should.have.been.calledWith(
          version, dimensions, 'original image')
        done()
      )

    it 'should put cropped image buffer in s3', (done) ->
      scope = nock('https://s3_bucket.s3.amazonaws.com')
        .put('/images/versions/version.png', "cropped image")
        .reply(200)
      image.uploadImageVersion(version, dimensions, (err) ->
        scope.done()
        done(err)
      )
