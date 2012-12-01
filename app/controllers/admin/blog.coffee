_ = require 'underscore'
async = require 'async'
errs = require 'errs'

app = require '../..'
Blog = require '../../models/blog'
BaseRoutes = require './base'

BLOGPOSTS_PER_PAGE = 20
PATH = 'admin/blog'
TYPE = 'Blog Post'

BlogRoutes = new BaseRoutes(Blog, PATH, TYPE)

exports.index = BlogRoutes.index(BLOGPOSTS_PER_PAGE)

exports.new = BlogRoutes.new()

exports.edit = BlogRoutes.edit()

exports.update = BlogRoutes.update()

exports.create = BlogRoutes.create()

exports.destroy = BlogRoutes.destroy()