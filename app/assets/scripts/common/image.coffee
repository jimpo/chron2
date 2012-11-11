define ['backbone', 'cs!common/util'], (Backbone, util) ->

  Backbone.Model.extend
    idAttribute: '_id'
    urlRoot: util.fullUrl('api', '/image')