require.config({
    shim: {
        'lib/backbone': {
            deps: ['jquery', 'lib/underscore'],
            exports: 'Backbone',
        },
    },
    baseUrl: '/scripts',
});

require([
    'cs!common/main','lib/bootstrap','cs!admin/crop','cs!admin/datepicker',
    'cs!admin/form-field','cs!admin/taxonomy', 'admin/upload'],
        function (main) {
            main.apply(this, arguments);
        });
