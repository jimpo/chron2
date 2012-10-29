require('coffee-script');
require('lib/util');

global.app = require('app');
global.server = require('server');

global.Browser = require('zombie');
global.sinon = require('sinon');
global.chai = require('chai');
global.should = require('chai').should();
global.expect = require('chai').expect;

var sinonChai = require('sinon-chai');
chai.use(sinonChai);

global.fullUrl = function (subdomain, path) {
    return 'http://' + subdomain + '.localhost:' + app.config.PORT + path;
};


var DatabaseCleaner = require('database-cleaner');

global.refreshDatabase = (function (databaseCleaner) {
    return function (callback) {
        databaseCleaner.clean(app.db.db, callback);
    };
})(new DatabaseCleaner('mongodb'));
