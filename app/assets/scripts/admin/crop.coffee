define ['jquery', 'lib/jquery.Jcrop', 'bootstrap'], ($) ->

  setCoordinates = (c) ->
    $('#x1').val(c.x)
    $('#y1').val(c.y)
    $('#x2').val(c.x2)
    $('#y2').val(c.y2)
    $('#w').val(c.w)
    $('#h').val(c.h)

  updateCropSize = ->
    dim = $('#sizes option:selected').data('dimensions')
    options =
      aspectRatio: dim.width / dim.height
      minSize: [dim.width, dim.height]
      setSelect: [0, 0, dim.width, dim.height]
    $('#crop-target').Jcrop(options)

  helpContent = ->
    descriptions = $('#sizes option').map ->
      info = $(this).data('dimensions')
      "<p><b>#{$(this).val()}</b>: #{info.description}</p>"
    descriptions.get().join("<br>")

  disableOptions = ->
    options = $('#sizes option').filter(->
      info = $(this).data('dimensions')
      $('#crop-target').width() < info.width or
        $('#crop-target').height() < info.height
    ).prop('disabled', true)
    $('#sizes option').filter(-> not $(this).attr('disabled')).first().prop('selected', true)

  '#crop-target': ->
    $(this).Jcrop(
      onChange: setCoordinates
      onSelect: setCoordinates
      onRelease: setCoordinates
    )
    $('#sizes').change(updateCropSize)
    disableOptions()
    updateCropSize()

  '.image-help': ->
    $('.image-help').popover(
      title: 'Image Versions'
      trigger: 'hover'
      html: true
      content: helpContent()
    )
