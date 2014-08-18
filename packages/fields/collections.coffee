@Data = new Meteor.Collection 'fields_data'
@Lists = new Meteor.Collection 'fields_lists'

if Meteor.isServer

    _createForm = (refId, fieldName, fieldValue) ->
        newField =
            _refId: refId
        newField[fieldName] = fieldValue

        Data.insert newField

    _createList = (listSpec) ->
        existingList = Lists.findOne {_refId: listSpec.refId, _listName: listSpec.listName}
        unless existingList?
            newList =
                _refId: listSpec.refId
                _listName: listSpec.listName
                _items: []
            id = Lists.insert newList
            existingList = Lists.findOne {_id: id}

        existingForm = Data.findOne {_refId: listSpec.refId}
        unless existingForm?
            id = _createForm listSpec.refId, listSpec.listName, existingList._id
            existingForm = Data.findOne {_id: id}

        unless existingForm[listSpec.listName]?
            val = {}
            val[listSpec.listName] = existingList._id
            Data.update {_id: existingForm._id}, {$set: val}

        existingList

    Meteor.publish '_fields_lists', (listSpec) ->
        existing = Lists.find {_refId: listSpec.refId, _listName: listSpec.listName}, {fields: {_items: 1, _refId: 1, _listName: 1}}
        if existing.count() is 0
            created = _createList listSpec
            existing = Lists.find {_id: created._id}, {fields: {_items: 1, _refId: 1, _listName: 1}}
        existing


    Meteor.methods
        _fields_init_ext_list_item: (para) ->
            Data.insert {_refId: para.refId, _extRef: para.extRef, _partOf: para.partOf}

    Meteor.publish '_fields_data_form', (id) ->
        Data.find {_id: id}

    Meteor.publish '_fields_data', (fieldSpec) ->
        fieldSelector = {}
        fieldSelector._refId = 1
        fieldSelector[fieldSpec.fieldName] = 1
        existing = Data.find {_refId: fieldSpec.refId}, {fields: fieldSelector}

        defaultValue = ''
        if fieldSpec.defaultValue?
            defaultValue = fieldSpec.defaultValue

        if existing.count() is 0
            id = _createForm fieldSpec.refId, fieldSpec.fieldName, defaultValue
            existing = Data.find {_id: id}, {fields: fieldSelector}

        existing

    @Data.allow
        insert: () ->
            false
        update: () ->
            true
        remove: () ->
            true

    @Lists.allow
        insert: () ->
            false
        update: () ->
            true
        remove: () ->
            true
