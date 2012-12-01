_ = require 'underscore'
async = require 'async'
errs = require 'errs'

Author = require '../../models/author'
Taxonomy = require '../../../lib/taxonomy'

class Base
  constructor: (model, path, type) ->

  index: (limit) ->
    model = @model
    path = @path
    return (req, res, next) ->
      limit = req.query.limit ? limit
      taxonomy = req.query.taxonomy?.split(',') ? []
      query = model.find().limit(limit).sort(created: 'desc')
      for section, i in taxonomy
        query.where("taxonomy.#{i}", section)
      query.exec (err, docs) ->
        res.render path + ''
          docs: docs
          messages: req.flash('info')

  new: =>
    path = @path
    return (req, res, next) ->
      res.render path + '/new'
        doc: {}
        errors: null
        taxonomy: Taxonomy.levels()

  edit: =>
    model = @model
    path = @path
    return (req, res, next) ->
      model.findOne(urls: req.params.url)
        .populate('authors')
        .populate('images.LargeRect.image')
        .populate('images.ThumbRect.image')
        .populate('images.ThumbRectL.image')
        .populate('images.ThumbSquareM.image')
        .populate('images.ThumbWide.image')
        .exec (err, doc) ->
          if err then return next(err)
          else if not doc?
            next()
          else
            res.render path + '/edit'
              doc: doc
              errors: null
              taxonomy: Taxonomy.levels()

  update: =>
    model = @model
    path = @path
    return (req, res, next) ->
      model.findOne {urls: req.params.url}, (err, doc) ->
        if err then return next err
        else if not doc?
          next()
        else
          flash = (message) ->
            req.flash('info', message)
          updateModel(doc, req.body.doc, flash, (err, retryErrors) ->
            if err then return next(err)
            else if retryErrors
              res.render path + '/edit'
                doc: req.body.doc
                errors: retryErrors
                taxonomy: Taxonomy.levels()
            else
              res.redirect '/'
          )

  create: =>
    model = @model
    path = @path
    return (req, res, next) ->
      flash = (message) ->
        req.flash('info', message)
      updateModel(new model, req.body.doc, flash, (err, retryErrors) ->
        if err then return next(err)
        else if retryErrors
          res.render path + '/new'
            doc: req.body.doc
            errors: retryErrors
            taxonomy: Taxonomy.levels()
        else
          res.redirect '/'
      )

  destroy: =>
    model = @model
    name = @type
    return (req, res, next) ->
      model.findOne {urls: req.params.url}, (err, doc) ->
        if err?
          errs.handle(err, next)
        else if not doc?
          res.send(404)
        else
          doc.remove (err) ->
            if err
              res.send(500, err)
            else
              req.flash('info', "#{name} \"#{doc.title}\" was deleted")
              res.send(200)

  updateModel = (docToUpdate, doc, flash, callback) ->
    name = @type
    doc.taxonomy = (section.toLowerCase() for section in doc.taxonomy when section)
    for type, image of doc.images
      if not (image.image and image.id)
        delete doc.images[type]
    doc.authors = (author for author in doc.authors when author)
    async.map(doc.authors, fetchOrCreateAuthor(flash), (err, authors) ->
      if err then return errs.handle(err, callback)
      doc.authors = (author._id for author in authors)
      docToUpdate.images = undefined  # will not remove images otherwise
      docToUpdate.set(doc)
      docToUpdate.addUrlForTitle (err) ->
        if err then return errs.handle(err, callback)
        docToUpdate.save (err) ->
          if err and err.name is 'ValidationError'
            callback(null, err.errors)
          else if err
            errs.handle(err, callback)
          else
            flash("#{name} \"#{docToUpdate.title}\" was saved")
            callback(err)
    )

  # TODO: this should perform bulk insertion of authors
  fetchOrCreateAuthor = (flash) ->
    (name, callback) ->
      Author.findOne {name: name}, '_id', (err, author) ->
        if err then return errs.handle(err, callback)
        else if author?
          callback(null, author)
        else
          author = new Author(name: name)
          author.save (err) ->
            flash?("Author \"#{name}\" was created")
            callback(err, author)


module.exports = Base