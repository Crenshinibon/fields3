Fields = {}
@Fields = Fields

class Fields._BaseField
    _ready: false
    _events: {beforeUpdate: undefined, afterUpdate: undefined}

    constructor: (para) ->
        self = @
        self._loadDeps = new Deps.Dependency
        self._events.beforeUpdate = para.events?.beforeUpdate
        self._events.afterUpdate = para.events?.afterUpdate

        self._fieldName = para.fieldName
        self._partOf = para.partOf
        self._extRef = para.extRef

        if para.id?
            self._id = para.id
        else
            unless self._extRef?
                self._id = Random.id()

        if self._id?
            self.inputId = "#{self._fieldName}#{self._id}input"
            self.createEvents()

            self._subscribe()
        else
            self.inputId = "ext#{self._fieldName}#{self._extRef}input"
            self.createEvents()

            fieldSpec =
                extRef: self._extRef
                fieldName: self._fieldName

            handle = Meteor.subscribe '_fields_data_by_extRef', fieldSpec, () ->
                self._id = Data.findOne({_extRef: self._extRef})._id
                handle.stop()
                self._subscribe()

    _subscribe: () ->
        self = @
        fieldSpec =
            id: self._id
            extRef: self._extRef
            fieldName: self._fieldName

        Meteor.autorun () ->
            Meteor.subscribe '_fields_data', fieldSpec, () ->
                self._ready = true
                self._loadDeps.changed()

    loading: () ->
        !@ready()
    
    ready: () ->
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
