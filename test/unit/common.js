require('coffee-script');
require('lib/util');

global.app = require('app');
global.sinon = require('sinon');
global.chai = require('chai');
global.should = require('chai').should();
global.expect = require('chai').expect;

var sinonChai = require('sinon-chai');
chai.use(sinonChai);
