define ['jquery', 'cs!common/image', 'backbone', 'lib/jade', 'bootstrap'],
  ($, Image, Backbone) ->

    selectImage = ->
      @options.$versionInput.val(@model.id)
      $('#image-select').modal('hide')

    ImageView = Backbone.View.extend
      events:
        click: selectImage

      render: ->
        @$el.html("<img src=\"#{this.model.fullUrl()}\" />")

    createModal = (version) ->
      template = $('#image-select-template').text()
      html = jade.compile(template)(versionType: version)
      $imageSelect = $(html)
      $imageSelect.modal('show').on('hidden', -> $(this).remove())

    '.image-picker': ->
      $(this).click (e) ->
        e.preventDefault()
        $versionInput = $(this).siblings('input')
        $imageSelect = createModal($(this).data('version'))
        collection = new Image.Collection
        collection.fetch
          error: -> alert('OMG')
          success: ->
            collection.each (image) ->
              view = new ImageView
                model: image
                $versionInput: $versionInput
              view.render()
              $imageSelect.find('.modal-body').append(view.$el)
