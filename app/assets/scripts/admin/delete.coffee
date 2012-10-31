define ['jquery', 'lib/bootstrap'], ->

  '.delete-article': ->
    $(this).click (e) =>
      e.preventDefault()
      $(this).attr('disabled', true)
      $.ajax($(this).data('url'),
        type: 'POST'  # Zombie does not send request body with DELETE
        data: {_csrf: $('#csrf').val(), _method: 'delete'}
        error: (err) =>
          console.log('Could not delete article: ' + err.statusText)
          alert('Could not delete article: ' + err.statusText)
          $(this).removeAttr('disabled')
        success: ->
          window.location = '/article'
      )
