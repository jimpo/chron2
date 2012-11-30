_ = require 'underscore'
async = require 'async'
errs = require 'errs'

app = require '../..'
Blog = require '../../models/blog'
Author = require '../../models/author'

BLOGPOSTS_PER_PAGE = 20

exports.index = (req, res, next) ->
  limit = req.query.limit ? BLOGPOSTS_PER_PAGE
  query = Blog.find().limit(limit).sort(created: 'desc')
  query.exec (err, blogs) ->
    res.render 'admin/blog'
      blogs: blogs
      messages: req.flash('info')

exports.new = (req, res, next) ->
  res.render 'admin/blog/new'
    doc: {}
    errors: null

exports.edit = (req, res, next) ->
  Blog.findOne(urls: req.params.url)
    .populate('authors')
    .populate('images.LargeRect.image')
    .populate('images.ThumbRect.image')
    .populate('images.ThumbRectL.image')
    .populate('images.ThumbSquareM.image')
    .populate('images.ThumbWide.image')
    .exec (err, blog) ->
      if err then return next(err)
      else if not blog?
        next()
      else
        res.render 'admin/blog/edit'
          doc: blog
          errors: null

exports.update = (req, res, next) ->
  Blog.findOne {urls: req.params.url}, (err, blog) ->
    if err then return next err
    else if not blog?
      next()
    else
      flash = (message) ->
        req.flash('info', message)
      updateBlog(blog, req.body.doc, flash, (err, retryErrors) ->
        if err then return next(err)
        else if retryErrors
          res.render 'admin/blog/edit'
            doc: req.body.doc
            errors: retryErrors
        else
          res.redirect '/'
      )

exports.create = (req, res, next) ->
  flash = (message) ->
    req.flash('info', message)
  updateBlog(new Blog, req.body.doc, flash, (err, retryErrors) ->
    if err then return next(err)
    else if retryErrors
      res.render 'admin/blog/new'
        doc: req.body.doc
        errors: retryErrors
    else
      res.redirect '/'
  )

exports.destroy = (req, res, next) ->
  Blog.findOne {urls: req.params.url}, (err, blog) ->
    if err?
      errs.handle(err, next)
    else if not blog?
      res.send(404)
    else
      blog.remove (err) ->
        if err
          res.send(500, err)
        else
          req.flash('info', "Blog Post \"#{blog.title}\" was deleted")
          res.send(200)

updateBlog = (blog, doc, flash, callback) ->
  for type, image of doc.images
    if not (image.image and image.id)
      delete doc.images[type]
  doc.authors = (author for author in doc.authors when author)
  async.map(doc.authors, fetchOrCreateAuthor(flash), (err, authors) ->
    if err then return errs.handle(err, callback)
    doc.authors = (author._id for author in authors)
    blog.images = undefined  # will not remove images otherwise
    blog.set(doc)
    blog.addUrlForTitle (err) ->
      if err then return errs.handle(err, callback)
      blog.save (err) ->
        if err and err.name is 'ValidationError'
          callback(null, err.errors)
        else if err
          errs.handle(err, callback)
        else
          flash("Blog \"#{blog.title}\" was saved")
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