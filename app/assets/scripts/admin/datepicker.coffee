define ['jquery', 'jquery-ui'], ($) ->
  '.datepicker': ->
    $(this).datepicker()
    $(this).datepicker('setDate', new Date($(this).val()))
