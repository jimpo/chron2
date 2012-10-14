fs = require 'fs'
path = require 'path'


# Require all files in the same dir as this one
# put them on the exports object
exports.requireAll = (dir, exports) ->
  for file in fs.readdirSync(dir)
    moduleName = file.replace(/\.coffee$/, '') if file.match /\.coffee$/
    if moduleName?
      exports[moduleName] = require(path.join(dir, moduleName))
