author = require('./authors').Author

exports.Article =
  'ash-gets-pikachu':
    title: 'Ash Gets Pikachu from Oak'
    body: '**Pikachu** refuses to enter pokeball'
    taxonomy: ['News']
    author: [author.Brock._id]
    urls: ['ash-gets-pikachu']
    created: new Date()
    updated: new Date()
