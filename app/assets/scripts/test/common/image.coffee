define ['backbone', 'cs!common/image', 'cs!common/util'],
  (Backbone, Image, util) ->

    describe 'Image', ->
      image = null

      beforeEach ->
        image = new Image

      it 'should extend Backbone.model', ->
        image.should.be.an.instanceOf Backbone.Model

      it 'should have _id as the idAttribute', ->
        image.idAttribute.should.equal '_id'

      it 'should use the image JSON api as the url', ->
        image.urlRoot.should.equal 'http://api.dukechronicle.com/image'
