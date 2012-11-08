define ['jquery', 'lib/bootstrap', '../../components/sinon.js/sinon'], ->

  '.delete-button': ->
    $(this).click (e) ->
      e.preventDefault()
      $(this).attr('disabled', true)
      $.ajax($(this).data('url'),
        type: 'POST'  # Zombie does not send request body with DELETE
        data: {_csrf: $('#csrf').val(), _method: 'delete'}
        error: (err) =>
          console.log('Could not delete: ' + err.statusText)
          alert('Could not delete: ' + err.statusText)
          $(this).removeAttr('disabled')
        success: =>
          if $(this).data('redirect')?
            window.location = $(this).data('redirect')
          else
            window.location.reload()
      )
