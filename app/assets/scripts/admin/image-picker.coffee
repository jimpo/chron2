define ['jquery', 'cs!common/image', 'bootstrap'], ($, Image) ->
  '.image-picker': ->
    $(this).click (e) ->
      e.preventDefault()
      version = $(this).data('version')
      $('#image-select .title').text("Select #{version} image")
      $('#image-select').modal('show')
      collection = new Image.Collection
      collection.fetch
        error: -> alert('OMG')
        success: ->
          collection.each (image) ->
            $('#image-select .modal-body').append(
              "<img src=\"#{image.fullUrl()}\" />")
