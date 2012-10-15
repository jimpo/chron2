Image = require 'app/models/image'


describe 'Image', ->
  image = null

  beforeEach ->
    image = new Image(
      caption: 'What? Pikachu is evolving'
      location: 'Vermillion City'
      photographer: 'Misty'
    )

  describe '#generateUrl()', ->
    it 'should set url to new url', ->
      url = image.generateUrl('raichu.png')
      expect(url).to.exist
      image.url.should.equal url

    it 'should consist of a random character sequence followed by filename', ->
      image.generateUrl('raichu.png').should.match /[a-zA-Z0-9]+\-raichu.png/
