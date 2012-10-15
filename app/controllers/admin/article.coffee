errs = require 'errs'

Article = require '../../models/article'

TAXONOMY = [
  [{name: 'News'}, {name: 'Sports'}]
  [{name: 'University', parent: 'News'}]
]

exports.new = (req, res, next) ->
  res.render 'admin/article/new'
    doc: {}
    errors: null
    taxonomy: TAXONOMY
    token: req.session._csrf

exports.edit = (req, res, next) ->
  Article.findOne {url: req.params.url}, (err, article) ->
    if err then return next(err)
    else if not article?
      console.log "article not found"
      next()
    else
      res.render 'admin/article/edit'
        doc: article
        errors: null
        taxonomy: TAXONOMY
        token: req.session._csrf

createArticle = (doc, callback) ->
  article = new Article(doc)
  article.taxonomy = section for section in article.taxonomy when section
  delete article.authors
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

exports.create = (req, res, next) ->
  createArticle req.body.doc, (err, retryErrors) ->
    if err then return next(err)
    else if retryErrors
      res.render 'admin/article/new'
        doc: req.body.doc
        errors: retryErrors
        taxonomy: TAXONOMY
        token: req.session._csrf
    else
      req.session.user = req.body.doc.username
      res.redirect '/'
