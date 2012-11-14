define ['backbone', 'cs!common/util'], (Backbone, util) ->

  Image = Backbone.Model.extend
    idAttribute: '_id'
    urlRoot: util.fullUrl('api', '/image')

    initialize: ->
      this.set('date', new Date(this.get('date'))) if this.has('date')

    extension: ->
      switch this.get('mimeType')
        when 'image/png' then '.png'
        when 'image/jpeg' then '.jpeg'
        when 'image/gif' then '.gif'
        else throw new Error('Unknown mime type: ' + this.get('mimeType'))

    fullUrl: ->
      filename = this.get('name') + this.extension()
      util.fullUrl('cdn', "/images/#{filename}")

  Image.Collection = Backbone.Collection.extend
    model: Image
    url: util.fullUrl('api', '/image')

  Image