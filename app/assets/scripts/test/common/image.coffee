define ['backbone', 'cs!common/image', 'cs!common/util'],
  (Backbone, Image, util) ->

    describe 'Image', ->
      image = null

      beforeEach ->
        image = new Image
          name: 'A8r9ub3o-squirtle'
          mimeType: 'image/png'
          caption: 'A water pokemon'
          date: new Date('10/30/12')

      it 'should extend Backbone.model', ->
        image.should.be.an.instanceOf Backbone.Model

      it 'should have _id as the idAttribute', ->
        image.idAttribute.should.equal '_id'

      it 'should use the image JSON api as the url', ->
        image.urlRoot.should.equal 'http://api.dukechronicle.com/image'

      describe '#fullUrl', ->
        it 'should be the CDN path to the image original', ->
          image.fullUrl().should.equal(
             'http://cdn.dukechronicle.com/images/A8r9ub3o-squirtle.png')

      describe.skip 'Collection', ->
