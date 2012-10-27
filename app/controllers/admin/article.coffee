_ = require 'underscore'
async = require 'async'
errs = require 'errs'

app = require '../..'
Article = require '../../models/article'
Author = require '../../models/author'
Taxonomy = require '../../../lib/taxonomy'

ARTICLES_PER_PAGE = 20


exports.index = (req, res, next) ->
  limit = req.query.limit ? ARTICLES_PER_PAGE
  taxonomy = req.query.taxonomy?.split(',') ? []
  query = Article.find().limit(limit).sort(created: 'desc')
  for section, i in taxonomy
    query.where("taxonomy.#{i}", section)
  query.exec (err, articles) ->
    res.render 'admin/article'
      articles: articles

exports.new = (req, res, next) ->
  res.render 'admin/article/new'
    doc: {}
    errors: null
    taxonomy: Taxonomy.levels()
    token: req.session._csrf

exports.edit = (req, res, next) ->
  Article.findOne(urls: req.params.url).populate('authors').exec(
    (err, article) ->
      if err then return next(err)
      else if not article?
        next()
      else
        res.render 'admin/article/edit'
          doc: article
          errors: null
          taxonomy: Taxonomy.levels()
          token: req.session._csrf
  )

exports.update = (req, res, next) ->
  Article.findOne {urls: req.params.url}, (err, article) ->
    if err then return next err
    else if not article?
      next()
    else
      flash = (message) ->
        app.log.info(message)
        req.flash('info', message)
      updateArticle(article, req.body.doc, flash, (err, retryErrors) ->
        if err then return next(err)
        else if retryErrors
          res.render 'admin/article/edit'
            doc: req.body.doc
            errors: retryErrors
            taxonomy: Taxonomy.levels()
            token: req.session._csrf
        else
          res.redirect '/'
      )

exports.create = (req, res, next) ->
  flash = (message) ->
    app.log.info(message)
    req.flash('info', message)
  updateArticle(new Article, req.body.doc, flash, (err, retryErrors) ->
    if err then return next(err)
    else if retryErrors
      res.render 'admin/article/new'
        doc: req.body.doc
        errors: retryErrors
        taxonomy: Taxonomy.levels()
        token: req.session._csrf
    else
      res.redirect '/'
  )

updateArticle = (article, doc, flash, callback) ->
  doc.taxonomy = (section.toLowerCase() for section in doc.taxonomy when section)
  doc.authors = (author for author in doc.authors when author)
  async.map(doc.authors, fetchOrCreateAuthor(flash), (err, authors) ->
    if err then return errs.handle(err, callback)
    doc.authors = (author._id for author in authors)
    article.set(doc)
    article.addUrlForTitle (err) ->
      if err then return errs.handle(err, callback)
      article.save (err) ->
        if err and err.name is 'ValidationError'
          callback(null, err.errors)
        else if err
          errs.handle(err, callback)
        else
          flash("Article \"#{article.title}\" was saved")
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
