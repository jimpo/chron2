_ = require 'underscore'
errs = require 'errs'
mongoose = require 'mongoose'

app = require '../app'


class Taxonomy extends mongoose.Types.Array

  constructor: (taxonomy, path, doc) ->
    node = findTaxonomyNode(taxonomy ? [])
    throw errs.create('InvalidTaxonomyError') if not node?
    arr = new mongoose.Types.Array(node.taxonomy, path, doc)
    arr.__proto__ = Taxonomy.prototype
    return arr

  taxonomy: ->
    _.toArray(this)

  children: ->
    node = findTaxonomyNode(this)
    throw errs.create('InvalidTaxonomy') if not node?
    (new Taxonomy(this.concat([childNode.name])) for childNode in node.children)

  parents: ->
    (new Taxonomy(this.slice(0, i)) for i in [1..this.length])

class SchemaTaxonomy extends mongoose.Schema.Types.Array
  constructor: (key, options) ->
    super(key, String, options)
    this.validate(validTaxonomy, 'Taxonomy is not valid')
    this.required()
    this.set (val) ->
      if val instanceof Taxonomy
        val
      else
        new Taxonomy(val)

findTaxonomyNode = (taxonomy) ->
  root = {children: app.config.TAXONOMY}
  fullTaxonomy = [];

  for section in taxonomy
    root = _.find(root.children || [], (child) ->
      child.name.toLowerCase() is section.toLowerCase()
    )
    return undefined if not root?
    fullTaxonomy.push(root.name)

  taxonomy: fullTaxonomy
  children: root.children

validTaxonomy = -> true

module.exports = Taxonomy
mongoose.Schema.Types.Taxonomy = SchemaTaxonomy
