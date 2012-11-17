define ['backbone', 'cs!common/util', 'underscore'], (Backbone, util) ->

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

    version: (versionId) ->
      _.find(this.get('versions'), (version) -> version._id is versionId)

    fullUrl: ->
      util.fullUrl('cdn', "/images/#{@id}#{this.extension()}")

  Image.Collection = Backbone.Collection.extend
    model: Image
    url: util.fullUrl('api', '/image')

  Image