errs = require 'errs'

Article = require '../../models/article'

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
