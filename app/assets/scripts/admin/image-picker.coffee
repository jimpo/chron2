define ['jquery', 'cs!common/image', 'backbone', 'lib/jade', 'bootstrap'],
  ($, Image, Backbone) ->

    ImageView = Backbone.View.extend
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
        $imageSelect = createModal($(this).data('version'))
        collection = new Image.Collection
        collection.fetch
          error: -> alert('OMG')
          success: ->
            collection.each (image) ->
              view = new ImageView(model: image)
              view.render()
              $imageSelect.find('.modal-body').append(view.$el)
