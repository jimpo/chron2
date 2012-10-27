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

  describe 'constructor', ->
    it 'should set taxonomy property with constructor argument', ->
      taxonomy = new Taxonomy(['News', 'University'])
      taxonomy.taxonomy().should.eql ['News', 'University']

    it 'should extend MongooseArray', ->
      taxonomy = new Taxonomy()
      taxonomy.should.be.an.instanceOf(mongoose.Types.Array)

  describe 'model integration', ->
    Pokemon = null

    before ->
      Pokemon = app.db.model('Pokemon', new mongoose.Schema(taxonomy: Taxonomy))

    it 'should get Taxonomy object from model', ->
      pikachu = new Pokemon(taxonomy: ['News', 'University'])
      pikachu.taxonomy.should.be.an.instanceOf Taxonomy
      pikachu.taxonomy.taxonomy().should.eql ['News', 'University']
