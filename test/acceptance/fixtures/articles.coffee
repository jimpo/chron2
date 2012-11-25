author = require('./authors').Author
image = require('./images').Image


exports.Article =
  ashGetsPikachu:
    title: 'Ash Gets Pikachu from Oak'
    body: '**Pikachu** refuses to enter pokeball'
    taxonomy: ['News']
    authors: [author.Brock._id]
    urls: ['ash-gets-pikachu-oak']
    created: new Date('12/12/12')
    images:
      LargeRect:
        image: image.squirtle._id
        id: image.squirtle.versions[0]._id
  ashBeatsFirstGym:
    title: 'Ash Beats the First Gym'
    body: '**Pikachu** is up against ground types'
    taxonomy: ['News']
    authors: []
    urls: ['ash-beats-first-gym']
    created: new Date('11/11/11')
    images:
      LargeRect:
        image: image.squirtle._id
        id: image.squirtle.versions[0]._id
