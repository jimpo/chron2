define ['lib/backbone'], (Backbone) ->

  Backbone.Model.extend
    urlRoot: '/api/page',
    idAttribute: '_id',
