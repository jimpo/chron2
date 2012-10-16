require.config({
    shim: {
        'lib/backbone': {
            deps: ['jquery', 'lib/underscore'],
            exports: 'Backbone',
        },
    },
    baseUrl: '/scripts',
});

require(['cs!common/main','cs!admin/crop','admin/delete-article',
         'admin/delete-image','admin/json-to-form','admin/k4export',
         'admin/layout','admin/newsletter','cs!admin/datepicker',
         'cs!admin/form-field','cs!admin/taxonomy','admin/upload',
         'cs!admin/page-layout', 'lib/bootstrap'],
        function (main) {
            main.apply(this, arguments);
        });
