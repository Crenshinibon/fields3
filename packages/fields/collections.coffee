#@Data = new Meteor.Collection 'fields_data'
#@Lists = new Meteor.Collection 'fields_lists'


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
        one = col.findOne {}, {$sort: {_index: -1}}
        if one?._index?
            one._index + 1
        else
            0

    _createForm = (para) ->
        newField =
            _id: para.id
            _extRef: para.extRef
            _created: new Date
            _form: para.form
            _index: _nextIndex para

        col = Fields._getCollection para.form
        col.insert newField

    _fieldSelector = (fieldName) ->
        fieldSelector =
            _id: 1
            _form: 1
            _extRef: 1
            _created: 1
            _index: 1
        fieldSelector[fieldName] = 1
        fieldSelector

    _initField = (para) ->
        col = Fields._getCollection para.form
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

        _initField para

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

        _initField para

        existing


    _itemSelector = () ->
        _index: 1
        _id: 1
        _extRef: 1
        _form: 1
        _created: 1

    Meteor.publish '_fields_list_items', (base) ->
        col = Fields._getCollection base
        col.find {}, {fields: _itemSelector()}


    Meteor.methods
        _fields_init_list_item: (para) ->
            _createForm para

###

_createList = (listSpec) ->
    newList =
        _refId: listSpec.refId
        _listName: listSpec.listName
        _items: []

    console.log newList

    id = Lists.insert newList
    Lists.findOne {_id: id}


Meteor.publish '_fields_lists', (listSpec) ->
    existing = Lists.find {_refId: listSpec.refId, _listName: listSpec.listName},
        {fields: {_items: 1, _refId: 1, _listName: 1}}

    if existing.count() is 0
        created = _createList listSpec
        existing = Lists.find {_id: created._id}, {fields: {_items: 1, _refId: 1, _listName: 1}}
    existing



Meteor.publish '_fields_data_form', (id) ->
    Data.find {_id: id}, {fields: {_id: 1, _partOf: 1, _extRef: 1}}



Meteor.publish '_fields_data', (fieldSpec) ->
    Data.find {_id: fieldSpec.id},
        {fields: _fieldSelector(fieldSpec.fieldName)}

###



