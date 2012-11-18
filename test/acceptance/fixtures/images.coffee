mongoose = require 'mongoose'
ObjectId = mongoose.Types.ObjectId


exports.Image =
  squirtle:
    _id: new ObjectId()
    filename: 'squirtle.png'
    caption: 'A water pokemon'
    date: new Date('10/30/12')
    versions: [{
      _id: new ObjectId()
      type: 'LargeRect'
      dim:
        x1: 20
        y1: 30
        x2: 720
        y2: 462
    }]
  charmander:
    _id: new ObjectId()
    filename: 'charmander.png'
    date: new Date('10/31/12')
    versions: [{
      _id: new ObjectId()
      type: 'ThumbRect'
      dim:
        x1: 20
        y1: 30
        x2: 206
        y2: 166
    }]
  bulbasaur:
    _id: new ObjectId()
    filename: 'bulbasaur.png'
    date: new Date('10/29/12')
    versions: []
