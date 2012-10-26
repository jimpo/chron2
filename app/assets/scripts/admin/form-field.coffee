define ['jquery'], ($) ->

  '.add-field': ->
    $(this).click (e) ->
      e.preventDefault()
      $items = $(this).parent().parent().children('li')
      index = $items.index($(this).parent())
      name = $(this).data('name') + "[#{index}]"
      $field = $('<li><input type="text"/></li>')
      $field.children('input').attr('name', name)
      $(this).parent().before($field)
