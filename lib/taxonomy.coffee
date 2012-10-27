_ = require 'underscore'
mongoose = require 'mongoose'


class Taxonomy extends mongoose.Types.Array

  constructor: (taxonomy, path, doc) ->
    arr = new mongoose.Types.Array(taxonomy, path, doc)
    arr.__proto__ = Taxonomy.prototype
    return arr

  taxonomy: ->
    _.toArray(this)

class SchemaTaxonomy extends mongoose.Schema.Types.Array
  constructor: (key, options) ->
    super(key, String, options)
    this.validate(validTaxonomy, 'Taxonomy is not valid')
    this.set (val) ->
      if val instanceof Taxonomy
        val
      else
        new Taxonomy(val)

validTaxonomy = -> true

module.exports = Taxonomy
mongoose.Schema.Types.Taxonomy = SchemaTaxonomy
