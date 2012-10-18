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
