require.config({
    shim: {
        'backbone': {
            deps: ['jquery', 'underscore'],
            exports: 'Backbone',
        },
    },
    baseUrl: '/scripts',
    paths: {
        'backbone': '../components/backbone/backbone',
        'bootstrap': '../components/bootstrap/docs/assets/js/bootstrap',
        'jquery-ui': '../components/jquery-ui/ui/jquery-ui',
        'underscore': '../components/underscore/underscore',
    }
});

require([
    'cs!common/main', 'cs!admin/crop', 'cs!admin/datepicker',
    'cs!admin/form-field', 'cs!admin/taxonomy', 'cs!admin/delete',
    'cs!admin/image-picker', 'cs!common/image', 'admin/upload'],
        function (main) {
            main.apply(this, arguments);
        });
