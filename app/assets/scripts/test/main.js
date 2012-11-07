require.config({
    shim: {
        'lib/backbone': {
            deps: ['jquery', 'lib/underscore'],
            exports: 'Backbone',
        },
    },
    baseUrl: '../../../app/assets/scripts',
    paths: {
        'mocha': '../components/mocha/mocha',
        'chai': '../components/chai/chai',
        'sinon': '../components/sinon.js/sinon',
    }
});

require(['require', 'chai', 'mocha', 'sinon'], function (require, chai) {
    mocha.setup('bdd');
    chai.should();
    require(['cs!common/main', MODULE, TEST], function (main, module) {
        main(main, module);
        mochaPhantomJS.run();
    });
});
