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
