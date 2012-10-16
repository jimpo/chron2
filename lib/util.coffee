_ = require 'underscore'
fs = require 'fs'
path = require 'path'

util = module.exports = require 'util'


# Require all files in the same dir as this one
# put them on the exports object
util.requireAll = (dir, exports) ->
  for file in fs.readdirSync(dir)
    moduleName = file.replace(/\.coffee$/, '') if file.match /\.coffee$/
    if moduleName and moduleName isnt 'index'
      exports[moduleName] = require(path.join(dir, moduleName))

util.random = (min, max) ->
  if not max?
    max = min
    min = 0
  min + Math.floor(Math.random() * (max - min + 1))

util.randomString = (n) ->
  chars = 'abcdefghijklmnopqrstuvwxyz'
  chars = chars + chars.toUpperCase() + [0..9].join('')
  (chars[util.random(0, chars.length)] for i in [0...n]).join('')
