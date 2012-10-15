async = require 'async'
errs = require 'errs'

Article = require '../../models/article'
Author = require '../../models/author'

TAXONOMY = [
  [{name: 'News'}, {name: 'Sports'}]
  [{name: 'University', parent: 'News'}]
]


exports.new = (req, res, next) ->
  taxonomy = [
    [{name: 'News'}, {name: 'Sports'}]
    [{name: 'University', parent: 'News'}]
  ]
  res.render 'admin/article/new'
    doc: {}
    errors: null
    taxonomy: TAXONOMY
    token: req.session._csrf

exports.create = (req, res, next) ->
  flash = (message) -> req.flash('info', message)
  createArticle req.body.doc, flash, (err, retryErrors) ->
    if err then return next(err)
    else if retryErrors
      res.render 'admin/article/new'
        doc: req.body.doc
        errors: retryErrors
        taxonomy: TAXONOMY
        token: req.session._csrf
    else
      req.flash('info', "Article \"#{req.body.doc.title}\" was created")
      res.redirect '/'

createArticle = (doc, flash, callback) ->
  doc.taxonomy = (section for section in doc.taxonomy when section)
  doc.authors = (author for author in doc.authors when author)
  async.map(doc.authors, fetchOrCreateAuthor(flash), (err, authors) ->
    if err then return errs.handle(err, callback)
    doc.authors = author._id for author in authors
    article = new Article(doc)
    article.addUrlForTitle (err) ->
      if err then return errs.handle(err, callback)
      article.validate (err) ->
        if err and err.name is 'ValidationError'
          callback(null, err.errors)
        else if err
          errs.handle(err, callback)
        else
          article.save (err) ->
            callback(err)
  )

fetchOrCreateAuthor = (flash) ->
  (name, callback) ->
    Author.findOne {name: name}, '_id', (err, author) ->
      if err then return errs.handle(err, callback)
      else if author?
        callback(null, author)
      else
        author = new Author(name: name)
        author.save (err) ->
          flash "Author \"#{name}\" was created"
          callback(err, author)
