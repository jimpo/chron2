define ['jquery', 'cs!common/image', 'backbone', 'lib/jade', 'bootstrap'],
  ($, Image, Backbone) ->

    selectImage = ->
      @options.$imagePicker.children('input').val(@model.id)
      setVisibilities(@options.$imagePicker)
      $('#image-select').modal('hide')

    ImageView = Backbone.View.extend
      events:
        click: selectImage

      render: ->
        version = @model.version(@options.version)
        @$el.html("<img src=\"#{version.fullUrl}\" />")

    createModal = (version) ->
      template = $('#image-select-template').text()
      html = jade.compile(template)(versionType: version)
      $imageSelect = $(html)
      $imageSelect.modal('show').on('hidden', -> $(this).remove())

    addImages = ($imageSelect, $imagePicker, collection, versionType) ->
      collection.each (image) ->
        for version in image.get('versions')
          if version.type is versionType
            view = new ImageView
              model: image
              version: version._id
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
