class Fields.List

    _ready: false
    _callbacks: {append: null, prepend: null, insert: null, remove: null, move: null}

    constructor: (para) ->
        self = @
        self._listName = para.listName
        self._refId = para.refId

        #must be called after being "connected"
        _initItems = (initial, current) ->
            current.forEach (e) ->
                Data.remove {_id: e}

            #insert new ones
            newIds = []
            initial.forEach (e) ->
                id = Meteor.call '_fields_init_ext_list_item',
                    refId: self._id
                    extRef: e
                    partOf: self._id

                newIds.push id

            Lists.update {_id: self._id}, {$set: {_items: newIds}}
            newIds


        #self._valueDeps = new Deps.Dependency
        self._loadDeps = new Deps.Dependency

        self.appendId = "#{self._listName}#{self._refId}append"
        self.prependId = "#{self._listName}#{self._refId}prepend"
        self.insertId = "#{self._listName}#{self._refId}insert"


        listSpec =
            listName: self._listName
            refId: self._refId

        Meteor.autorun () ->
            Meteor.subscribe '_fields_lists', listSpec, () ->
                list = Lists.findOne({_refId: self._refId, _listName: self._listName})
                self._id = list._id

                items = list._items;
                console.log items
                if para.items? and para.items.length? and para.items.length > 0
                    items = _initItems para.items, items

                console.log items
                if items.length > 0
                    countReady = 0
                    items.forEach (e) ->
                        Meteor.subscribe '_fields_data_form', e, () ->
                            countReady += 1
                            if countReady is list._items.length
                                self._ready = true
                                self._loadDeps.changed()
                else
                    self._ready = true
                    self._loadDeps.changed()

        @createEvents()

    loading: () ->
        !@ready()

    ready: () ->
        @_loadDeps.depend()
        @_ready

    items: () ->
        self = @
        erg = []
        if self.ready()
            l = Lists.findOne {_id: self._id}
            erg = l._items.map (e) ->
                Data.findOne {_id: e}
               
            #console.log l
        else
            erg = []
        erg

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
            
        _registerListEvents eventMap
    
    append: () ->
        self = @
        extRef = undefined
        if self._callbacks.append?
            extRef = self._callbacks.append.call self

        id = Meteor.call '_fields_init_ext_list_item',
            refId: self._id
            extRef: extRef
            partOf: self._id

        Lists.update {_id: self._id}, {$push: {_items: id}}