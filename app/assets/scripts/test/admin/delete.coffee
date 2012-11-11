define ['jquery'], ($) ->

  describe 'delete', ->
    describe 'when .delete-button is clicked', ->
      $button = event = xhr = requests = null

      beforeEach ->
        sinon.stub(window.location, 'reload')
        xhr = sinon.useFakeXMLHttpRequest()
        requests = []
        xhr.onCreate = (xhr) -> requests.push(xhr)
        $button = $('.delete-button')
        event = jQuery.Event('click')
        $button.trigger(event)

      afterEach ->
        window.location.reload.restore()
        xhr.restore()

      it 'should prevent default action', ->
        event.isDefaultPrevented().should.be.true

      it 'should disable the button', ->
        $button.attr('disabled').should.exist

      it 'should make an ajax request', ->
        requests.should.have.length 1

      it 'should post to the specified url', ->
        requests[0].url.should.equal 'http://www.example.com/delete'
        requests[0].method.should.equal 'POST'

      it 'should post with the csrf token', ->
        requests[0].requestBody.should.contain '_csrf=abcdefgh'

      it 'should post "_method=delete"', ->
        requests[0].requestBody.should.contain '_method=delete'

      describe 'when server responds successfully', ->
        beforeEach ->
          requests[0].respond(200)

        it 'should reload page', ->
          window.location.reload.should.have.been.called

      describe 'when server responds with failure', ->
        beforeEach ->
          requests[0].respond(500)

        it.skip 'should alert user of failure', ->

        it 'should reenable button', ->
          expect($button.attr('disabled')).not.to.exist

        it 'should not reload page', ->
          window.location.reload.should.not.have.been.called