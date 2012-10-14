require('coffee-script');

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
