define ['jquery', 'lib/bootstrap'], ->

  '.delete-article': ->
    $(this).click (e) =>
      e.preventDefault()
      $(this).attr('disabled', true)
      console.log $(this).data('url')
      console.log(
        type: 'DELETE',
        data: {_csrf: $('#csrf').val()},
        error: (error) ->
          alert(error)
        success: ->
          window.location = '/article'
      )
      $.ajax($(this).data('url'),
        type: 'DELETE'
        data: {_csrf: $('#csrf').val()}
        error: (err) =>
          alert('Could not delete article: ' + err.statusText)
          $(this).removeAttr('disabled')
        success: ->
          window.location = '/article'
      )
