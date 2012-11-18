require.config({
    shim: {
        'backbone': {
            deps: ['jquery', 'underscore'],
            exports: 'Backbone',
        },
    },
    baseUrl: '../../../app/assets/scripts',
    paths: {
        'backbone': '../components/backbone/backbone',
        'bootstrap': '../components/bootstrap/docs/assets/js/bootstrap',
        'chai': '../components/chai/chai',
        'mocha': '../components/mocha/mocha',
        'sinon': '../components/sinon.js/sinon',
        'underscore': '../components/underscore/underscore',
    }
});


require(
    ['require', 'chai', 'lib/sinon-chai', 'cs!common/util', 'mocha', 'sinon'],
    function (require, chai, sinonChai, util) {
        mocha.setup('bdd');
        chai.should();
        chai.use(sinonChai);

        util.fullUrl = function (subdomain, path) {
            return 'http://' + subdomain + '.dukechronicle.com' + path;
        }

        window.expect = chai.expect;
        if (typeof MODULE !== 'undefined') {
            require(['cs!common/main', MODULE, TEST], function (main, module) {
                main(main, module);
                mochaPhantomJS.run();
            });
        }
        else {
            require([TEST], function () {
                mochaPhantomJS.run();
            });
        }
    });
