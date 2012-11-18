mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId


exports.Author =
  Brock:
    _id: new ObjectId()
    name: 'Brock'
    affiliation: 'Pewter City Gym Leader'
