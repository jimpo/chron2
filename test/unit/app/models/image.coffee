_ = require 'underscore'
fs = require 'fs'
im = require 'imagemagick'
path = require 'path'

Image = require 'app/models/image'


describe 'Image', ->
  image = null

  beforeEach ->
    image = new Image(
      caption: 'What? Pikachu is evolving'
      location: 'Vermillion City'
      photographer: 'Misty'
    )

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

  describe '#generateUrl()', ->
    it 'should set url to new url', ->
      url = image.generateUrl('raichu.png')
      expect(url).to.exist
      image.url.should.equal url

    it 'should consist of a random character sequence followed by filename', ->
      image.generateUrl('raichu.png').should.match /^[a-zA-Z0-9]+\-raichu.png/


  describe '#generateUrlForVersion()', ->
    it 'should set url to new url', ->
      image.versions.push(type: 'LargeRect')
      version = image.versions[0]
      url = image.generateUrlForVersion(version, 20, 30)
      expect(url).to.exist
      version.url.should.equal url

    it 'should append the version\'s crop information to the original url', ->
      image.url = 'abcdefgh-raichu.png'
      image.versions.push(type: 'LargeRect')
      version = image.versions[0]
      image.generateUrlForVersion(version, 20, 30).should.equal(
        '636x393-20-30-abcdefgh-raichu.png')

  describe '#download()', ->
    it.skip 'should fetch file from s3'
    it.skip 'should callback with binary buffer of file contents'

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
      image.url = 'original.jpg'
      image.versions.push(type: 'LargeRect', url: 'version.jpg')
      version = image.versions[0]
      fs.readFile path.join(__dirname, '../../../pikachu.jpg'), 'binary', (err, data) ->
        buffer = data
        done(err)

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
      imSpy = sinon.spy(im, 'convert')
      image.cropImage(version, dimensions, buffer, (err, cropped) ->
        if err then return done(err)
        im.convert.restore()
        dest = _.last(imSpy.firstCall.args[0])
        fs.readFile dest, 'binary', (err, buffer) ->
          if err then return done(err)
          cropped.should.equal buffer
          done()
      )

    it.skip 'should remove images written to disk'