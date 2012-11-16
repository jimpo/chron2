define ['jquery', 'cs!common/image', 'backbone', 'underscore', 'bootstrap'],
  ($, Image, Backbone) ->

    selectImage = ($imagePicker, version) ->
      $imagePicker.children('input').val(version?._id)
      $imagePicker.children('.image-display').attr(
        'data-content', version and "<img src=\"#{version.fullUrl}\" />")
      setVisibilities($imagePicker)
      $('#image-select').modal('hide')

    ImageView = Backbone.View.extend
      events:
        click: ->
          selectImage(@options.$imagePicker, @options.version)

      render: ->
        @$el.html("<img src=\"#{@options.version.fullUrl}\" />")

    createModal = (version) ->
      template = $('#image-select-template').text()
      html = _.template(template, {versionType: version})
      $imageSelect = $(html)
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
        console.log $(this).data('url')
        $(this).popover
          html: true
          trigger: 'hover'

      $(this).on 'click', '.image-remove', (e) ->
        e.preventDefault()
        $imagePicker = $(this).parents('.image-picker').first()
        selectImage($imagePicker, undefined)

      $(this).on 'click', '.image-attach', (e) ->
        e.preventDefault()
        $imagePicker = $(this).parents('.image-picker').first()
        versionType = $imagePicker.data('version')
        $versionInput = $imagePicker.children('input')
        $imageSelect = createModal(versionType)

        collection = new Image.Collection
        collection.fetch
          error: -> alert('OMG')
          success: ->
            addImages($imageSelect, $imagePicker, collection, versionType)
