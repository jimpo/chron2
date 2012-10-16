_ = require 'underscore'
errs = require 'errs'
mongoose = require 'mongoose'
util = require 'util'

app = require '../../app'

IMAGE_TYPES =
  LargeRect:
    width: 636
    height: 393
    description: "Used as the image on the article page, as well as for slideshows and featured article positions on the layouts. All article images should have it."
  ThumbRect:
    width: 186,
    height: 133,
    description: "Used as the thumbnail for articles on all layout pages, and in the newsletter. Any image for an article that will be on the layout should have it."
  ThumbRectL:
    width: 276
    height: 165
    description: "Used for the first article in each of the following layout groups: the Frontpage layout page for the Recess and Towerview groups, the Towerview layout page for the Savvy and Wisdom groups, and the Recess layout page for the Music, Film, and Art groups."
  ThumbSquareM:
    width: 200
    height: 200
    description: "Used for articles on the towerview layout that are in the featured group in position 2 or 3, and for articles in the sports layout in the stories group. Used as the columnist image on the opinion page. Also used as the picture facebook shows when people like or share articles."
  ThumbWide:
    width: 300
    height: 120
    description: "Used for articles on the towerview layout that are in the prefix group."


imageVersion = new mongoose.Schema
  type: {type: String, required: true, enum: _.keys(IMAGE_TYPES)}
  url: {type: String, required: true}

imageSchema = new mongoose.Schema
  caption: String
  date: {type: Date, default: Date.now}
  location: String
  photographer: String
  versions: {type: [imageVersion], default: []}
  url: {type: String, required: true, unique: true}

imageSchema.methods.generateUrl = (filename) ->
  @url = util.randomString(8) + '-' + filename

imageVersion.methods.generateUrl = (x1, y1, original) ->
  type = IMAGE_TYPES[@type]
  @url = "#{type.width}x#{type.height}-#{x1}-#{y1}-#{original}"

imageSchema.virtual('fullUrl').get ->
  "#{app.config.CONTENT_CDN}/images/#{@url}"

imageSchema.virtual('name').get ->
  @url.replace(/\.(gif|jpe?g|png)$/, '')

Image = module.exports = app.db.model 'Image', imageSchema
Image.IMAGE_TYPES = IMAGE_TYPES
