Package.describe({
    summary: 'A package to provide convenient, self managing form fields'
});

Package.on_use(function (api) {
    api.use('standard-app-packages', ['client', 'server']);
    api.use('coffeescript',['client','server']);
    api.use('reactive-dict',['client']);

    //libs
    //api.add_files('bootstrap-wysiwyg/bootstrap-wysiwyg.js', 'client');
    //api.add_files('bootstrap-wysiwyg/jquery.hotkeys.js', 'client');
    //api.export('wysiwyg');

    //api.add_files('momentjs/moment-with-langs.js','client');
    //api.export('moment');

    //api.add_files('namespace.coffee',['client', 'server']);
    //api.export('Fields');

    //api.add_files('fields-templates.html','client');

    api.add_files('bootstrap-wysiwyg/jquery.hotkeys.js',['client']);
    api.add_files('bootstrap-wysiwyg/bootstrap-wysiwyg.js',['client']);


    api.add_files('namespace.coffee',['client','server']);

    api.add_files('client-templates.html', ['client']);

    api.add_files('client-helpers.coffee', ['client']);

    api.add_files('collections.coffee', ['client', 'server']);

    api.add_files('base.coffee',['client']);

    api.add_files('list.coffee',['client']);

    api.add_files('simple-text.coffee',['client']);

    api.add_files('text-area.coffee',['client']);

    api.add_files('select.coffee',['client']);

    api.add_files('server-methods.coffee',['server']);

    api.add_files('access.coffee',['client','server']);

    api.export('Fields');


    //api.add_files('form-client.coffee','client');
});