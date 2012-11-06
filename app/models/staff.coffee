errs = require 'errs'
mongoose = require 'mongoose'

app = require '../../app'


staffSchema = new mongoose.Schema
  
  affiliation: String
  biography: String
  currentColumnist: {type: Boolean, default: false}
  name: {type: String, required: true}
  positions: [{ title: String, year: Date }]
  tagline: String
  twitter: String
  photo: Schema.ObjectId

Staff = module.exports = app.db.model 'Staff', staffSchema

//addNewPosition (void)
authorSchema.methods.addNewPosition =null;

//isAuthor (boolean)

//isPhotog (boolean)

//isDeveloper (boolean)

//

