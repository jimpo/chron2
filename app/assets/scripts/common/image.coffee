define ['backbone', 'cs!common/util'], (Backbone, util) ->

  Backbone.Model.extend
    idAttribute: '_id'
    urlRoot: util.fullUrl('api', '/image')

    extension: ->
      switch this.get('mimeType')
        when 'image/png' then '.png'
        when 'image/jpeg' then '.jpeg'
        when 'image/gif' then '.gif'
        else throw new Error('Unknown mime type: ' + this.get('mimeType'))

    fullUrl: ->
      filename = this.get('name') + this.extension()
      util.fullUrl('cdn', "/images/#{filename}")