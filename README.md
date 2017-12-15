# Chronline Node.js Training Application

## Project

The actual project is to create a calendar system on top of this basic application. You will want to create some sort of Event model and have some routes to submit events and view a listing of events or some sort of calendar view html. For example, you might consider the following routes to follow a somewhat RESTful architecture:

- `GET`    /event?view=<calendar view style> -- show calendar of events
- `GET`    /event/:event-id                  -- show event
- `GET`    /event/new                        -- form to create new event
- `POST`   /event                            -- submit new event route
- `DELETE` /event/:event-id                  -- delete event
- `GET`    /event/:event-id/edit             -- form to edit event
- `PUT`    /event/:event-id                  -- update event

## Getting Started

- Get [git](https://help.github.com/articles/set-up-git)
- Install Node.js using [nvm](https://github.com/creationix/nvm)
- Install [npm](http://npmjs.org/): `$ curl https://npmjs.org/install.sh | sh`
- Create a [Github](http://github.com/) account
- Add your [public key](https://help.github.com/articles/generating-ssh-keys) to Github
- [Fork](https://help.github.com/articles/fork-a-repo) this repository
- Clone the forked repository
- `$ make install`
- `$ make run`
- Create the [`config.js`](#configuration) file
- Check your browser at `http://localhost:4000` for the application
- Start coding 8)

## Application Architecture

- `server.js`      -- This file is the main executable that creates and starts the application. Keep it small.
- `config.js`      -- This stores the [configuration](#configuration) variables. It should not be added to the repository.
- `lib/`
-   `route.js`     -- All application routing goes here.
-   `helpers.js`   -- Helper functions defined here are available in the Jade template engine.
-   `models/`      -- All Mongoose models are defined in separate modules in this directory.
-   `controllers/` -- Each controller should have a different resource.
-   `util/`        -- Utility functions.
- `test/           -- Tests go in here. Tests are written with Mocha.
-   `unit/`
-   `acceptance/`
- `Makefile`       -- A Makefile with the targets `install`, `run`, `test-unit`, and `test-acceptance`.
- `package.json`   -- Node.js package file. List all npm dependencies here.

Testing, both acceptance and unit, is *highly* encouraged, but not required. It can definitely get annoying to write tests, but it is worth it.

## Configuration

The `config.js` file should be filled out like so:

``` js
module.exports = {
    db: 'mongodb://username:pass@mongo.example.com:port/database',
    port: 4000,
};
```

You are free to add any configuration parameters you require.

## Resources

- [Web Servers](http://computer.howstuffworks.com/web-server.htm)
- [HTML](http://www.w3schools.com/html/default.asp)
- [CSS](http://www.w3schools.com/css/default.asp)
- [Traditional Javascript](http://www.w3schools.com/js/default.asp)
- [jQuery](http://www.jquery.com)
- [Node.js](http://nodejs.org/)
- [Node.js Tutorial](http://nodemanual.org/latest/)
- [MongoDB](http://www.mongodb.org/display/DOCS/Tutorial)
- [Express](http://expressjs.com/)
- [Jade](https://github.com/visionmedia/jade)
- [Stylus](http://learnboost.github.com/stylus/)
- [Mongoose](http://mongoosejs.com/)
- [Mocha Testing Framework](http://mochajs.org/)
