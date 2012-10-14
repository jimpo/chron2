bcrypt = require 'bcrypt'
errs = require 'errs'
mongoose = require 'mongoose'

app = require '../../app'

EMAIL_PATTERN = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i

userSchema = new mongoose.Schema(
  username:
    type: String
    required: true
    unique: true
  name:
    type: String
    required: true
  email:
    type: String
    required: true
    match: EMAIL_PATTERN
  passwdHash:
    type: String
    required: true
)

userSchema.methods.setPassword = (passwd, callback) ->
  bcrypt.genSalt (err, salt) =>
    if err then return errs.handle(err, callback)
    bcrypt.hash(passwd, salt, (err, hash) =>
      if err then return errs.handle(err, callback)
      @passwdHash = hash
      callback()
    )

userSchema.methods.matchesPassword = (passwd, callback) ->
  if not @passwdHash?
    return callback(errs.create
      message: 'User has no password set'
    )
  bcrypt.compare(passwd, @passwdHash, callback)

module.exports = app.db.model 'User', userSchema
