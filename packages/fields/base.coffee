Fields = {}
@Fields = Fields

class Fields._BaseField
    _ready: false
    _events: {beforeUpdate: null, afterUpdate: null}
    _loadDeps: new Deps.Dependency

    constructor: (para) ->
        self = @
        self._events.beforeUpdate = para.events?.beforeUpdate
        self._events.afterUpdate = para.events?.afterUpdate

        self._fieldName = para.fieldName
        self._partOf = para.partOf
        self._extRef = para.extRef

        if para.listContext?
            self._id = para.listContext._id
            self._extRef = para.listContext._extRef
            self._partOf = para.listContext._partOf


        if para.id? and not self._id
            self._id = para.id
        else
            unless self._extRef?
                self._id = Random.id()

        if self._id?
            self.inputId = "#{self._fieldName}#{self._id}input"
            self._subscribe para.onReady
        else
            self.inputId = "ext#{self._fieldName}#{self._extRef}input"
            fieldSpec =
                extRef: self._extRef
                fieldName: self._fieldName

            handle = Meteor.subscribe '_fields_data_by_extRef', fieldSpec, () ->
                self._id = Data.findOne({_extRef: self._extRef})._id
                handle.stop()
                self._subscribe para.onReady

    _subscribe: (onReady) ->
        self = @
        fieldSpec =
            id: self._id
            extRef: self._extRef
            fieldName: self._fieldName

        Meteor.autorun () ->
            Meteor.subscribe '_fields_data', fieldSpec, () ->
                self._ready = true
                self._loadDeps.changed()

                if self._partOf?
                    console.log 'sub returned2: ', self, @

                if onReady?
                    onReady.call self

    loading: () ->
        !@ready()
    
    ready: () ->
        if @_partOf?
            console.log 'ready called', @
        @_loadDeps.depend()
        @_ready

    value: () ->
        self = @
        
        value = '...loading...'
        if self.ready()
            d = Data.findOne self._id
            if d?
                value = d[self._fieldName]
                unless value?
                    value = ''
            else
                value = ''
        
        value

    update: (newValue) ->
        self = @

        val = {}
        val[self._fieldName] = newValue

        Data.update {_id: self._id}, {$set: val}

    #override this function in concrete implementations
    createEvents: () ->
