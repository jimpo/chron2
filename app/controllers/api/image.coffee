errs = require 'errs'

Image = require '../../models/image'


exports.index = (req, res, next) ->
  query = Image.find().sort(date: 'desc')
  query.limit(req.query.limit) if req.query.limit?
  query.exec (err, images) ->
    return errs.handle(err, next) if err?
    res.json(200, images)
