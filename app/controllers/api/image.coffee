_ = require 'underscore'
errs = require 'errs'

Image = require '../../models/image'


exports.index = (req, res, next) ->
  query = Image.find().sort(date: 'desc')
  query.limit(req.query.limit) if req.query.limit?
  query.exec (err, images) ->
    return errs.handle(err, next) if err?
    images = _.map images, (model) ->
      image = model.toJSON()
      image.fullUrl = model.fullUrl
      for i in [0...image.versions.length]
        image.versions[i].fullUrl = model.versions[i].fullUrl()
      image
    res.json(200, images)
