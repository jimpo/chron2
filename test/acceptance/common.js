var DatabaseCleaner = require('database-cleaner');
var fixtures = require('mongodb-fixtures');
var path = require('path');

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

global.refreshDatabase = (function (databaseCleaner) {
    return function (callback) {
        databaseCleaner.clean(app.db.db, function (err) {
            if (err) return callback(err);
            fixtures.load(path.join(__dirname, 'fixtures'));
            sinon.stub(app.db.db, 'open').yields();
            fixtures.save(app.db.db, function (err) {
                delete propertyPlural;
                app.db.db.open.restore();
                callback(err);
            });
        });
    };
})(new DatabaseCleaner('mongodb'));
