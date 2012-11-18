define ['jquery'], ($) ->

  describe 'image-picker', ->
    it 'should show attach button', ->
      $('.image-picker > .image-attach').is(':visible').should.be.true

    it 'should hide change, remove, and display options', ->
      $('.image-picker .image-change').is(':hidden').should.be.true
      $('.image-picker .image-display').is(':hidden').should.be.true

    describe 'when it is clicked', ->
      event = xhr = requests = null

      before ->
        sinon.stub(window.location, 'reload')
        xhr = sinon.useFakeXMLHttpRequest()
        requests = []
        xhr.onCreate = (xhr) -> requests.push(xhr)
        event = jQuery.Event('click')
        $('.image-picker > .image-attach').trigger(event)

      after ->
        $('#image-select .close').click()

      it 'should prevent default action', ->
        event.isDefaultPrevented().should.be.true

      it 'should pop open a dialog', ->
        $('#image-select').length.should.be.gt 0
        $('#image-select').hasClass('modal').should.be.true
        $('#image-select').is(':visible').should.be.true

      it 'should make an ajax request', ->
        requests.should.have.length 1

      it 'should load most recent images', ->
        requests[0].url.should.equal 'http://api.dukechronicle.com/image'
        requests[0].method.should.equal 'GET'

      describe 'when server responds successfully', ->
        image =
          _id: '12345',
          mimeType: 'image/png',
          name: 'pikachu',
          date: '2012-11-18T03:03:58.050Z',
          fullUrl: 'http://cdn.dukechronicle.com/images/12345.png'
          versions: [
            {
              type: 'LargeRect',
              _id: '23456',
              dim: {x1: 15, y1: 134, x2: 850, y2: 650}
              fullUrl: 'http://cdn.dukechronicle.com/images/versions/23456.png'
            }
            {
              type: 'LargeRect',
              _id: '34567',
              dim: {x1: 15, y1: 134, x2: 850, y2: 650}
              fullUrl: 'http://cdn.dukechronicle.com/images/versions/34567.png'
            }
          ]

        beforeEach ->
          requests[0].respond(200, {}, JSON.stringify([image]))

        it 'should display all correct versions of images', ->
          $('#image-select img').should.have.length 2
          $('#image-select img').eq(0).attr('src').should.equal(
            'http://cdn.dukechronicle.com/images/versions/23456.png')
          $('#image-select img').eq(1).attr('src').should.equal(
            'http://cdn.dukechronicle.com/images/versions/34567.png')