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

        _fields_find_field_by_extRef: (para) ->
            existing = Data.findOne({_extRef: para.extRef})
            unless existing?
                unless para.id?
                    para.id = Random.id()
                _createForm para
            else
                existing._id

    Meteor.publish '_fields_data_form', (id) ->
        Data.find {_id: id}, {fields: {_id: 1, _partOf: 1, _extRef: 1}}


    Meteor.publish '_fields_data', (fieldSpec) ->
        fieldSelector = {}
        fieldSelector._id = 1
        fieldSelector._partOf = 1
        fieldSelector._extRef = 1
        fieldSelector[fieldSpec.fieldName] = 1
        existing = Data.find {_id: fieldSpec.id}, {fields: fieldSelector}
        ###
        defaultValue = ''
        if fieldSpec.defaultValue?
            defaultValue = fieldSpec.defaultValue

        if existing.count() is 0
            _createForm fieldSpec
            existing = Data.find {_id: fieldSpec.id}, {fields: fieldSelector}
        ###
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
