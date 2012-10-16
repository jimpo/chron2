define ['jquery', 'lib/backbone'], ($, Backbone) ->

  Backbone.View.extend

    initialize: (@property, @schema) ->

    template: _.template($('#group-template').text());

    render: (index) ->
      label = @schema.name
      label += " (#{String.fromCharCode(65 + index)})" if index?
      $(this.el).html(this.template(label: label))
      this
