errs = require 'errs'

Article = require '../../models/article'


exports.new = (req, res, next) ->
  res.render 'admin/author/new'
    doc: {}
    errors: null
    token: req.session._csrf
