class Fields.List
    constructor: (para) ->
        self = @

        self._callbacks = {append: null, prepend: null, insert: null, remove: null, move: null}
        self._para = para

        self._localData = new ReactiveDict
        self._localData.set 'ready', false

        self._collection = Fields._getCollection para.base

        self._itemsSubscribe()

        self._addControlElementIds()
        self.createEvents()

    _itemsSubscribe: () =>
        self = @
        Meteor.subscribe '_fields_list_items', self._para, () ->
            self._localData.set 'ready', true

    _addControlElementIds: () =>
        self = @
        self._baseUIID = Random.id()
        self.appendId = "#{self._para.listName}#{self._baseUIID}append"
        self.prependId = "#{self._para.listName}#{self._baseUIID}prepend"

    items: () =>
        self = @

        self._collection.find {_listName: self._para.listName},
            {sort: {_index: 1}, fields: {_index: 1, _form: 1, _id: 1, _listName: 1}}


    loading: () =>
        !@ready()

    ready: () =>
        @_localData.get 'ready'

    onAppend: (cb) =>
        @_callbacks.append = cb

    onPrepend: (cb) =>
        @_callbacks.prepend = cb

    onInsert: (cb) =>
        @_callbacks.insert = cb

    onMove: (cb) =>
        @_callbacks.move = cb

    onRemove: (cb) =>
        @_callbacks.remove = cb

    createEvents: () =>
        self = @

        eventMap = {}
        eventMap["click .#{self.appendId}"] = (e) ->
            self.append()

        Template._list.events eventMap
    
    append: () =>
        self = @

        if self.ready()

            newItem =
                id: Random.id()
                form: self._para.base
                listName: self._para.listName

            Meteor.call '_fields_init_list_item', newItem