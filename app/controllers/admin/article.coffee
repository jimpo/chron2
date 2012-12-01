_ = require 'underscore'
async = require 'async'
errs = require 'errs'

app = require '../..'
Article = require '../../models/article'
BaseRoutes = require './base'

ARTICLES_PER_PAGE = 20
PATH = 'admin/article'
TYPE = 'Article'

ArticleRoutes = new BaseRoutes(Article, PATH, TYPE)

exports.index = ArticleRoutes.index(ARTICLES_PER_PAGE)

exports.new = ArticleRoutes.new()

exports.edit = ArticleRoutes.edit()

exports.update = ArticleRoutes.update()

exports.create = ArticleRoutes.create()

exports.destroy = ArticleRoutes.destroy()
