_ = require 'underscore'
async = require 'async'
errs = require 'errs'
fs = require 'fs'
im = require 'imagemagick'
mime = require 'mime'
mongoose = require 'mongoose'
path = require 'path'
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
  dim:
    x1: {type: Number}
    x2: {type: Number}
    y1: {type: Number}
    y2: {type: Number}

imageVersion.methods.name = ->
  type = IMAGE_TYPES[@type]
  [w, h, x1, x2, y1, y2] = [
    type.width
    type.height
    @dim.x1
    @dim.x2
    @dim.y1
    @dim.y2
  ]
  "#{w}x#{h}-#{x1}-#{y1}-#{x2}-#{y2}-#{this.__parent.name}"

imageVersion.methods.filename = ->
  this.name() + '.' + mime.extension(this.__parent.mimeType)

imageVersion.methods.url = ->
  '/images/versions/' + this.filename()

imageVersion.methods.fullUrl = ->
  app.config.CONTENT_CDN + this.url()

imageVersion.methods.upload = (callback) ->
  async.waterfall([
    (callback) => this.__parent.download(callback)
    (buffer, callback) => this.__parent.crop(this, buffer, callback)
    (buffer, callback) =>
      headers =
        'Content-Length': buffer.length
        'Content-Type': this.__parent.mimeType
        'Cache-Control': 'public,max-age=' + 365.25 * 24 * 60 * 60
      req = app.s3.put(this.url(), headers)
      req.on('response', (res) -> app.s3.handleResponse(res, callback))
      req.end(buffer)
    ],
    callback
  )

imageVersion.methods.removeImage = (callback) ->
  app.s3.deleteFile this.url(), (err, res) ->
    return errs.handle(err, callback) if err?
    app.s3.handleResponse(res, callback)

imageSchema = new mongoose.Schema
  caption: String
  date: {type: Date, default: Date.now}
  location: String
  photographer: String
  versions: {type: [imageVersion], default: []}
  mimeType: {type: String, required: true, match: /image\/[a-z\-]+/}
  name: {type: String, required: true, unique: true}

imageSchema.methods.download = (callback) ->
  app.s3.getFile @url, (err, res) ->
    if err then return callback(err)
    res.setEncoding('binary')
    app.s3.handleResponse(res, callback)

imageSchema.methods.upload = (fileInfo, callback) ->
  headers =
    'Content-Type': fileInfo.mime
    'Content-Length': fileInfo.length
    'Cache-Control': 'public,max-age=' + 365.25 * 24 * 60 * 60
  app.s3.putFile(fileInfo.path, @url, headers, callback)

imageSchema.methods.removeImage = (callback) ->
  app.s3.deleteFile @url, (err, res) ->
    return errs.handle(err, callback) if err?
    app.s3.handleResponse(res, callback)

imageSchema.methods.removeVersion = (id, callback) ->
  version = this.versions.id(id)
  if not version?
    return errs.handle('Version does not exist', callback)
  image = version.__parent
  version.removeImage (err) ->
    return errs.handle(err, callback) if err?
    version.remove()
    image.save(callback)

imageSchema.methods.crop = (version, buffer, callback) ->
  type = IMAGE_TYPES[version.type]
  dim =
    x1: version.dim.x1
    y1: version.dim.y1
    w: version.dim.x2 - version.dim.x1
    h: version.dim.y2 - version.dim.y1
  tmpdir = path.join(__dirname, '../../tmp')
  src = path.join(tmpdir, @filename)
  dest = path.join(tmpdir, 'cropped-' + @filename)
  fs.writeFile src, buffer, 'binary', (err) ->
    if err then return errs.handle(err, callback)
    geometry = "#{dim.w}x#{dim.h}+#{dim.x1}+#{dim.y1}"
    dimensions = "#{type.width}x#{type.height}"
    im.convert(['-crop', geometry, '-resize', dimensions, src, dest], (err) ->
      if err then return errs.handle(err, callback)
      fs.readFile(dest, 'binary', callback)

      # cropImage does not need to wait for temporary files to be removed
      fs.unlink src, (err) ->
        app.log.warning(errs.merge(err, {
          message: "Temporary file #{src} could not be removed"
        })) if err?

      fs.unlink dest, (err) ->
        app.log.warning(errs.merge(err, {
          message: "Temporary file #{dest} could not be removed"
        })) if err?
    )

imageSchema.pre 'remove', (next) ->
  async.forEach(this.versions,
    (version, callback) -> version.removeImage(callback)
    (err) =>
      return next(err) if err?
      this.removeImage(next)
  )

imageSchema.virtual('filename').get ->
  @name + '.' + mime.extension(@mimeType)

imageSchema.virtual('filename').set (filename) ->
  extension = path.extname(filename)
  @name = util.randomString(10) + '-' + path.basename(filename, extension)
  @mimeType = mime.lookup(filename)

imageSchema.virtual('url').get ->
  '/images/' + @filename

imageSchema.virtual('fullUrl').get ->
  app.config.CONTENT_CDN + @url

Image = module.exports = app.db.model 'Image', imageSchema
Image.IMAGE_TYPES = IMAGE_TYPES
