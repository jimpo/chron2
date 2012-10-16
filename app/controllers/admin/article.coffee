async = require 'async'
errs = require 'errs'

app = require '../..'
Article = require '../../models/article'
Author = require '../../models/author'

ARTICLES_PER_PAGE = 20
TAXONOMY = [
  [{name: 'News'}, {name: 'Sports'}]
  [{name: 'University', parent: 'News'}]
]


exports.index = (req, res, next) ->
  Article.find().limit(20).sort(created: 'desc').exec (err, articles) ->
    res.render 'admin/article'
      articles: articles

exports.new = (req, res, next) ->
  res.render 'admin/article/new'
    doc: {}
    errors: null
    taxonomy: TAXONOMY
    token: req.session._csrf

exports.edit = (req, res, next) ->
  Article.findOne({urls: req.params.url}).populate('authors').exec(
    (err, article) ->
      if err then return next(err)
      else if not article?
        next()
      else
        res.render 'admin/article/edit'
          doc: article
          errors: null
          taxonomy: TAXONOMY
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
            taxonomy: TAXONOMY
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
        taxonomy: TAXONOMY
        token: req.session._csrf
    else
      res.redirect '/'
  )

updateArticle = (article, doc, flash, callback) ->
  doc.taxonomy = (section for section in doc.taxonomy when section)
  doc.authors = (author for author in doc.authors when author)
  async.map(doc.authors, fetchOrCreateAuthor(flash), (err, authors) ->
    if err then return errs.handle(err, callback)
    doc.authors = (author._id for author in authors)
    article.set(doc)
    article.addUrlForTitle (err) ->
      if err then return errs.handle(err, callback)
      article.validate (err) ->
        if err and err.name is 'ValidationError'
          callback(null, err.errors)
        else if err
          errs.handle(err, callback)
        else
          article.save (err) ->
            if err then return errs.handle(err, callback)
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
