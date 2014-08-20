@Data = new Meteor.Collection 'fields_data'
@Lists = new Meteor.Collection 'fields_lists'

if Meteor.isServer

    _createForm = (para) ->
        console.log 'createForm:', para
        newField =
            _id: para.id
            _extRef: para.extRef
            _partOf: para.partOf

        if para.fieldName?
            newField[para.fieldName] = para.fieldValue

        Data.insert newField

    _createList = (listSpec) ->
        existingList = Lists.findOne {_id: listSpec.id, _listName: listSpec.listName}
        unless existingList?
            newList =
                _refId: listSpec.refId
                _listName: listSpec.listName
                _items: []
            id = Lists.insert newList
            existingList = Lists.findOne {_id: id}

        existingForm = Data.findOne {_id: listSpec.id}
        unless existingForm?
            id = _createForm listSpec
            existingForm = Data.findOne {_id: id}

        unless existingForm[listSpec.listName]?
            val = {}
            val[listSpec.listName] = existingList._id
            Data.update {_id: existingForm._id}, {$set: val}

        existingList


    #TODO
    Meteor.publish '_fields_lists', (listSpec) ->
        existing = Lists.find {_refId: listSpec.refId, _listName: listSpec.listName}, {fields: {_items: 1, _refId: 1, _listName: 1}}
        if existing.count() is 0
            created = _createList listSpec
            existing = Lists.find {_id: created._id}, {fields: {_items: 1, _refId: 1, _listName: 1}}
        existing

    Meteor.methods
        _fields_init_list_item: (para) ->
            _createForm para

    Meteor.publish '_fields_data_form', (id) ->
        Data.find {_id: id}, {fields: {_id: 1, _partOf: 1, _extRef: 1}}


    _fieldSelector = (fieldName) ->
        fieldSelector = {}
        fieldSelector._id = 1
        fieldSelector._partOf = 1
        fieldSelector._extRef = 1
        fieldSelector[fieldName] = 1
        fieldSelector

    Meteor.publish '_fields_data', (fieldSpec) ->
        Data.find {_id: fieldSpec.id}, {fields: _fieldSelector(fieldSpec.fieldName)}

    Meteor.publish '_fields_data_by_extRef', (fieldSpec) ->
        existing = Data.find {_extRef: fieldSpec.extRef}, {fields: _fieldSelector(fieldSpec.fieldName)}

        if existing.count() > 0
            existing
        else
            fieldSpec.id = Random.id()
            _createForm fieldSpec
            Data.find {_id: fieldSpec.id}, {fields: _fieldSelector(fieldSpec)}

    @Data.allow
        insert: () ->
            false
        update: () ->
            true
        remove: () ->
            false

    @Lists.allow
        insert: () ->
            false
        update: () ->
            true
        remove: () ->
            false