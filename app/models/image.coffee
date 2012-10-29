_ = require 'underscore'
async = require 'async'
errs = require 'errs'
fs = require 'fs'
im = require 'imagemagick'
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

imageSchema.methods.generateUrlForVersion = (version, x1, y1) ->
  type = IMAGE_TYPES[version.type]
  version.url = "#{type.width}x#{type.height}-#{x1}-#{y1}-#{this.url}"

imageSchema.methods.download = (callback) ->
  app.s3.getFile("/images/#{@url}", (err, res) ->
    if err then return callback(err)
    data = ''
    res.setEncoding('binary')
    res.on('data', (chunk) -> data += chunk)
    res.on('end', ->
      err = undefined
      switch res.statusCode
        when 200 then err = undefined
        when 403 then err = 'Forbidden'
        else err = 'Unknown error'

      if err?
        res.message = err
        callback(errs.create('S3Error', res))
      else
        callback(undefined, data)
    )
    res.on('close', callback)
  )

imageSchema.methods.upload = (fileInfo, callback) ->
  headers =
    'Content-Type': fileInfo.mime
    'Content-Length': fileInfo.length
    'Cache-Control': 'public,max-age=' + 365.25 * 24 * 60 * 60
  app.s3.putFile(fileInfo.path, "/images/#{@url}", headers, callback)

imageSchema.methods.uploadImageVersion = (version, dim, callback) ->
  async.waterfall([
    (callback) => this.download(callback)
    (buffer, callback) => this.cropImage(version, dim, buffer, callback)
    (buffer, callback) =>
      headers =
        'Content-Length': buffer.length
        'Content-Type': @mimeType
        'Cache-Control': 'public,max-age=' + 365.25 * 24 * 60 * 60
      url = "/images/versions/#{version.url}"
      req = app.s3.put(url, headers)
      req.on('response', (res) ->
        err = undefined
        switch res.statusCode
          when 200 then err = undefined
          when 403 then err = 'Forbidden'
          else err = 'Unknown error'

        if err?
          res.message = err
          callback(errs.create('S3Error', res))
        else
          callback()
      )
      req.end(buffer)
    ],
    callback
  )

imageSchema.methods.cropImage = (version, dim, buffer, callback) ->
  type = IMAGE_TYPES[version.type]
  tmpdir = path.join(__dirname, '../../tmp')
  src = path.join(tmpdir, @url)
  dest = path.join(tmpdir, version.url)
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

imageSchema.methods.fullUrl = (version) ->
  baseUrl = app.config.CONTENT_CDN + '/images/'
  baseUrl + (if version then "versions/#{version.url}" else @url)

imageSchema.virtual('name').get ->
  @url.replace(/\.(gif|jpe?g|png)$/, '')

imageSchema.virtual('mimeType').get ->
  switch path.extname(@url).toLowerCase()
    when '.gif' then 'image/gif'
    when '.png' then 'image/png'
    when '.jpg' then 'image/jpeg'
    when '.jpeg' then 'image/jpeg'

Image = module.exports = app.db.model 'Image', imageSchema
Image.IMAGE_TYPES = IMAGE_TYPES
