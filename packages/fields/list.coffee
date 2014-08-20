class Fields.List
    _ready: false
    _callbacks: {append: null, prepend: null, insert: null, remove: null, move: null}
    _baseField: null
    _loadDeps: new Deps.Dependency

    constructor: (para) ->
        self = @
        self._listName = para.listName
        self._baseField = new Fields._BaseField
            fieldName: para.listName
            partOf: para.partOf
            id: para.id
            extRef: para.extRef
            onReady: () ->
                self._subscribe()

        self._addControlElementIds()
        @createEvents()

    _addControlElementIds: () ->
        self = @
        unless self._baseField._id?
            self.appendId = "#{self._listName}#{self._baseField._extRef}append"
            self.prependId = "#{self._listName}#{self._baseField._extRef}prepend"
            self.insertId = "#{self._listName}#{self._baseField._extRef}insert"
        else
            self.appendId = "ext#{self._listName}#{self._baseField._id}append"
            self.prependId = "ext#{self._listName}#{self._baseField._id}prepend"
            self.insertId = "ext#{self._listName}#{self._baseField._id}insert"

    _subscribe: () ->
        self = @
        listSpec =
            listName: self._listName
            extRef: self._baseField._extRef
            id: self._baseField._id

        Meteor.autorun () ->
            Meteor.subscribe '_fields_lists', listSpec, () ->
                list = Lists.findOne({_refId: self._baseField._id, _listName: self._listName})
                self._listId = list._id
                self._baseField.update list._id

                #TODO recreate list items from extRef items

                if list._items.length > 0
                    countReady = 0
                    list._items.forEach (e) ->
                        Meteor.subscribe '_fields_data_form', e, () ->
                            countReady += 1
                            if countReady is list._items.length
                                self._ready = true
                                self._loadDeps.changed()
                else
                    self._ready = true
                    self._loadDeps.changed()

    loading: () ->
        !@ready()

    ready: () ->
        @_loadDeps.depend()
        @_ready

    items: () ->
        self = @
        if self.ready()
            Data.find {_partOf: self._listId}
        else
            []

    onAppend: (cb) ->
        @_callbacks.append = cb

    onPrepend: (cb) ->
        @_callbacks.prepend = cb

    onInsert: (cb) ->
        @_callbacks.insert = cb

    onMove: (cb) ->
        @_callbacks.move = cb

    onRemove: (cb) ->
        @_callbacks.remove = cb

    createEvents: () ->
        self = @
        
        eventMap = {}
        eventMap["click .#{self.appendId}"] = () ->
            self.append()
            
        Template._list.events eventMap
    
    append: () ->
        self = @

        newForm = {id: Random.id(), partOf: self._listId}

        #call external hook to get extRef id
        if self._callbacks.append?
            newForm.extRef = self._callbacks.append.call self

        Meteor.call '_fields_init_list_item', newForm,
            (e, res) ->
                Lists.update {_id: self._listId},
                    {$push: {_items: res}}