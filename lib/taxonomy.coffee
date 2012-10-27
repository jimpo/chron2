mongoose = require 'mongoose'

validTaxonomy = -> true

class Taxonomy

class SchemaTaxonomy extends mongoose.Schema.Types.Array
  constructor: (key, options) ->
    super(key, String, options)
    this.validate(validTaxonomy, 'Taxonomy is not valid')

module.exports = Taxonomy
mongoose.Schema.Types.Taxonomy = SchemaTaxonomy
