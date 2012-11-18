define ['jquery', 'cs!common/image', 'backbone', 'underscore', 'bootstrap'],
  ($, Image, Backbone) ->

    selectImage = ($imagePicker, image, version) ->
      $imagePicker.children('input.image-id').val(image.id)
      $imagePicker.children('input.version-id').val(version._id)
      $imagePicker.children('.image-display').attr(
        'data-content', "<img src=\"#{image.fullUrl(version._id)}\" />")
      setVisibilities($imagePicker)
      $('#image-select').modal('hide')

    removeImage = ($imagePicker) ->
      $imagePicker.children('input.image-id').val(undefined)
      $imagePicker.children('input.version-id').val(undefined)
      $imagePicker.children('.image-display').removeAttr('data-content')
      setVisibilities($imagePicker)

    ImageView = Backbone.View.extend
      events:
        click: ->
          selectImage(@options.$imagePicker, @model, @options.version)

      render: ->
        @$el.html("<img src=\"#{@options.version.fullUrl}\" />")

    createModal = (version) ->
      template = $('#image-select-template').text()
      html = _.template(template, {versionType: version})
      $imageSelect = $(html)
      $('body').append($imageSelect)
      $imageSelect.modal('show').on('hidden', -> $(this).remove())

    addImages = ($imageSelect, $imagePicker, collection, versionType) ->
      collection.each (image) ->
        for version in image.get('versions')
          if version.type is versionType
            view = new ImageView
              model: image
              version: version
              $imagePicker: $imagePicker
            view.render()
            $imageSelect.find('.modal-body').append(view.$el)

    setVisibilities = ($imagePicker) ->
      if $imagePicker.children('input').val()
        $imagePicker.children('.image-attach').hide()
        $imagePicker.find('.image-change').show()
        $imagePicker.children('.image-display').show()
      else
        $imagePicker.children('.image-attach').show()
        $imagePicker.children('.image-change').hide()
        $imagePicker.children('.image-display').hide()

    '.image-picker': ->
      $(this).each -> setVisibilities $(this)

      $(this).children('.image-display').each ->
        url = $(this).data('url')
        $(this).attr('data-content', "<img src=\"#{url}\" />") if url?
        $(this).popover
          html: true
          trigger: 'hover'

      $(this).on 'click', '.image-remove', (e) ->
        e.preventDefault()
        $imagePicker = $(this).parents('.image-picker').first()
        removeImage($imagePicker)

      $(this).on 'click', '.image-attach', (e) ->
        e.preventDefault()
        $imagePicker = $(this).parents('.image-picker').first()
        versionType = $imagePicker.data('version')
        $versionInput = $imagePicker.children('input')
        $imageSelect = createModal(versionType)

        collection = new Image.Collection
        collection.fetch
          error: -> console.log 'OMG'
          success: (data) ->
            addImages($imageSelect, $imagePicker, collection, versionType)
