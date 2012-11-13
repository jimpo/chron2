errs = require 'errs'


# TODO: https://github.com/jashkenas/coffee-script/issues/2359


class S3Error extends Error then constructor: -> super

errs.register('S3Error', S3Error)

exports.S3Error = S3Error
