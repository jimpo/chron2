define ['jquery', 'bootstrap'], ->
  '.image-picker': ->
    $(this).click (e) ->
      e.preventDefault()
      version = $(this).data('version')
      $('#image-select .title').text("Select #{version} image")
      $('#image-select').modal('show')
