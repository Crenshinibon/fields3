Fields._collections = {}
Fields._getCollection = (form) ->
    unless form?
        return new Meteor.Collection(null)

    name = 'fields' + form
    unless Fields._collections[name]?
        col = new Meteor.Collection name
        if Meteor.isServer
            col.allow
                insert: () ->
                    false
                update: () ->
                    true
                remove: () ->
                    false

        Fields._collections[name] = col
        col
    else
        Fields._collections[name]

if Meteor.isServer

    _nextIndex = (para) ->
        col = Fields._getCollection para.form
        one = col.findOne {_listName: para.listName},
            {sort: {_index: -1}}

        if one?
            one._index + 1
        else
            0

    _createForm = (para) ->
        newField =
            _id: para.id
            _extRef: para.extRef
            _created: new Date
            _form: para.form

        if para.listName?
            newField._listName = para.listName
            newField._index = _nextIndex para

        col = Fields._getCollection para.form
        col.insert newField

    _fieldSelector = (fieldName) ->
        fieldSelector = _itemSelector()
        fieldSelector[fieldName] = 1
        fieldSelector

    _initField = (para, col) ->
        one = col.findOne {_id: para.id}
        unless one?[para.fieldName]?
            val = {}
            val[para.fieldName] = para.defaultValue
            col.update {_id: para.id}, {$set: val}


    Meteor.publish '_fields_form_field', (para) ->
        col = Fields._getCollection para.form
        existing = col.find {_id: para.id},
            {fields: _fieldSelector(para.fieldName)}
        if existing.count() is 0
            _createForm para
            existing = col.find {_id: para.id},
                {fields: _fieldSelector(para.fieldName)}

        _initField para, col

        existing

    Meteor.publish '_fields_form_field_byExtRef', (para) ->
        col = Fields._getCollection para.form
        existing = col.find {_extRef: para.extRef},
            {fields: _fieldSelector(para.fieldName)}

        if existing.count() is 0
            para.id = Random.id()
            _createForm para
            existing = col.find {_id: para.id},
                {fields: _fieldSelector(para.fieldName)}

        _initField para, col

        existing


    _itemSelector = () ->
        _index: 1
        _id: 1
        _extRef: 1
        _form: 1
        _listName: 1
        _created: 1

    Meteor.publish '_fields_list_items', (para) ->
        col = Fields._getCollection para.base
        col.find {_listName: para.listName}, {fields: _itemSelector()}


    Meteor.methods
        _fields_init_list_item: (para) ->
            _createForm para

