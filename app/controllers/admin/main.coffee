exports.index = (req, res, next) ->
  res.render 'admin'
    messages: req.flash('info')
