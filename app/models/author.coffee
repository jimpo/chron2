errs = require 'errs'
mongoose = require 'mongoose'

app = require '../../app'


authorSchema = new mongoose.Schema
  
  affiliation: String
  biography: String
  currentColumnist: {type: Boolean, default: false}
  name: {type: String, required: true}
  positions: [{ title: String, year: Date }]
  tagline: String
  twitter: String
  photo: Schema.ObjectId

Author = module.exports = app.db.model 'Author', authorSchema

//addNewPosition (void)
authorSchema.methods.addNewPosition =null;


//isAuthor (boolean)

//isPhotog (boolean)

//isDeveloper (boolean)

//

