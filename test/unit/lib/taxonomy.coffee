mongoose = require 'mongoose'

Taxonomy = require 'lib/taxonomy'


describe 'Taxonomy', ->
  it 'should not be a SchemaType', ->
    taxonomy = new Taxonomy
    taxonomy.should.not.be.an.instanceOf(mongoose.SchemaType)

  it 'should be usable in a Schema', ->
    schema = new mongoose.Schema(taxonomy: Taxonomy)
    taxonomy = schema.path('taxonomy')
    taxonomy.should.be.an.instanceOf(mongoose.SchemaType)

  describe 'model integration', ->
    Pokemon = null

    before ->
      Pokemon = app.db.model('Pokemon', new mongoose.Schema(taxonomy: Taxonomy))

    it 'should do stuff', ->
      taxonomy = new Taxonomy(['News', 'University'])
      pikachu = new Pokemon(taxonomy: taxonomy)
