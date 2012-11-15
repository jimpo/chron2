define ['jquery', 'cs!common/image', 'lib/jade', 'bootstrap'], ($, Image) ->
  '.image-picker': ->
    $(this).click (e) ->
      e.preventDefault()
      version = $(this).data('version')
      template = $('#image-select-template').text()
      html = jade.compile(template)(versionType: version)
      $imageSelect = $(html)
      $imageSelect.modal('show').on('hidden', -> $(this).remove())
      collection = new Image.Collection
      collection.fetch
        error: -> alert('OMG')
        success: ->
          collection.each (image) ->
            $imageSelect.find('.modal-body').append(
              "<img src=\"#{image.fullUrl()}\" />")
