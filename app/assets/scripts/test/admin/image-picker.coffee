define ['jquery'], ($) ->

  describe 'image-picker', ->
    it 'should show attach button', ->
      $('.image-picker > .image-attach').is(':visible').should.be.true

    it 'should hide change, remove, and display options', ->
      $('.image-picker .image-change').is(':hidden').should.be.true
      $('.image-picker .image-display').is(':hidden').should.be.true

    describe.skip 'when it is clicked', ->
      it 'should prevent default action', ->
      it 'should pop open a dialog', ->
      it 'should load correct versions of most recent images', ->
      it 'should display all correct versions of images', ->
