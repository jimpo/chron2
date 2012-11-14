define ['backbone', 'cs!common/image', 'cs!common/util'],
  (Backbone, Image, util) ->

    describe 'Image', ->
      squirtle =
        name: 'A8r9ub3o-squirtle'
        mimeType: 'image/png'
        caption: 'A water pokemon'
        date: new Date('10/30/12')

      image = null

      beforeEach ->
        image = new Image(squirtle)

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

      describe 'Collection', ->
        collection = null

        beforeEach ->
          collection = new Image.Collection

        describe '#fetch()', ->
          xhr = requests = callbacks = null

          beforeEach ->
            xhr = sinon.useFakeXMLHttpRequest()
            requests = []
            xhr.onCreate = (request) ->
              requests.push(request)
            callbacks =
              error: sinon.stub()
              success: sinon.stub()
            collection.fetch(callbacks)

          afterEach ->
            xhr.restore()

          it 'should make an api request to /image', ->
            requests.should.have.length 1
            requests[0].url.should.equal 'http://api.dukechronicle.com/image'
            requests[0].method.should.equal 'GET'

          describe 'when server responds with images', ->
            beforeEach ->
              requests[0].respond(200, {}, JSON.stringify([squirtle]))

            it 'should execute success callback', ->
              callbacks.success.should.have.been.called
              callbacks.error.should.not.have.been.called

            it 'should create an Image model in the collection', ->
              collection.should.have.length 1
              collection.first().should.be.an.instanceOf Image

            it 'should create a model with server JSON', ->
              collection.first().toJSON().should.eql squirtle

          describe 'when server encounters an error', ->
            beforeEach ->
              requests[0].respond(500)

            it 'should execute error callback', ->
              callbacks.success.should.not.have.been.called
              callbacks.error.should.have.been.called
