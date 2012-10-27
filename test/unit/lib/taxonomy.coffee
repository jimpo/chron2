mongoose = require 'mongoose'

Taxonomy = require 'lib/taxonomy'


describe 'Taxonomy', ->
  before ->
    app.config ?= {}
    app.config.TAXONOMY = [{
      name: 'News',
      children: [{
        name: 'University',
        children: [
          { name: 'Academics', children: [] }
        ]}
      ]},
      {
        name: 'Sports',
        children: [] }
    ]

  it 'should not be a SchemaType', ->
    taxonomy = new Taxonomy
    taxonomy.should.not.be.an.instanceOf(mongoose.SchemaType)

  it 'should be usable in a Schema', ->
    schema = new mongoose.Schema(taxonomy: Taxonomy)
    taxonomy = schema.path('taxonomy')
    taxonomy.should.be.an.instanceOf(mongoose.SchemaType)

  describe 'constructor', ->
    it 'should extend MongooseArray', ->
      taxonomy = new Taxonomy()
      taxonomy.should.be.an.instanceOf(mongoose.Types.Array)

    it 'should set taxonomy to root by default', ->
      taxonomy = new Taxonomy()
      taxonomy.taxonomy().should.eql []

    it 'should throw error if taxonomy is invalid', ->
      constructor = -> new Taxonomy(['fake', 'section'])
      constructor.should.throw(Error, /InvalidTaxonomy/)

    it 'should set taxonomy to normalized taxonomy', ->
      taxonomy = new Taxonomy(['news', 'university'])
      taxonomy.taxonomy().should.eql ['News', 'University']

  describe '#taxonomy()', ->
    taxonomy = null

    before ->
      taxonomy = new Taxonomy(['News', 'University'])

    it 'should return taxonomy as an array', ->
      taxonomy.taxonomy().should.be.an('Array')

    it 'should return taxonomy as an array', ->
      taxonomy.taxonomy().should.eql ['News', 'University']

  describe '#name()', ->
    it 'should be the last section in the taxonomy', ->
      taxonomy = new Taxonomy(['News', 'University'])
      taxonomy.name().should.equal 'University'

  describe '#path()', ->
    it 'should be the taxonomy lowercased and separated by slashes', ->
      taxonomy = new Taxonomy(['News', 'University', 'Academics'])
      taxonomy.path().should.equal '/news/university/academics'

  describe '#children()', ->
    it 'should return an array of child nodes', ->
      taxonomy = new Taxonomy(['news'])
      taxonomy.children().should.eql [
        new Taxonomy(['News', 'University'])
      ]

  describe '#parents()', ->
    it 'should return an array of ancestor nodes', ->
      taxonomy = new Taxonomy(['news', 'university', 'academics'])
      taxonomy.parents().should.eql [
        new Taxonomy(['News'])
        new Taxonomy(['News', 'University'])
        new Taxonomy(['News', 'University', 'Academics'])
      ]

  describe 'mainSections()', ->
    it 'should return names of top level sections', ->
      Taxonomy.mainSections().should.eql ['News', 'Sports']

  describe 'model integration', ->
    Pokemon = null

    before ->
      Pokemon = app.db.model('Pokemon', new mongoose.Schema(taxonomy: Taxonomy))

    it 'should get Taxonomy object from model', ->
      pikachu = new Pokemon(taxonomy: ['News', 'University'])
      pikachu.taxonomy.should.be.an.instanceOf Taxonomy
      pikachu.taxonomy.taxonomy().should.eql ['News', 'University']

    it 'should create model with invalid taxonomy', ->
      constructor = -> new Pokemon(taxonomy: ['fake', 'section'])
      constructor.should.not.throw(Error)

    it 'should be invalid without a taxonomy', (done) ->
      pikachu = new Pokemon()
      pikachu.validate (err) ->
        expect(err).to.exist
        err.name.should.equal 'ValidationError'
        err.errors.should.have.property 'taxonomy'
        done()
