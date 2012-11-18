author = require('./authors').Author
image = require('./images').Image


exports.Article =
  'ash-gets-pikachu':
    title: 'Ash Gets Pikachu from Oak'
    body: '**Pikachu** refuses to enter pokeball'
    taxonomy: ['News']
    author: [author.Brock._id]
    urls: ['ash-gets-pikachu-oak']
    created: new Date()
    updated: new Date()
    images:
      LargeRect:
        image: image.squirtle._id
        id: image.squirtle.versions[0]._id
