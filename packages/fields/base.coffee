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

        self._refId = para.refId
        self._fieldName = para.fieldName
        self._partOf = para.partOf

        self.inputId = "#{self._fieldName}#{self._refId}input"

        unless para.partOf?
            self._extRef = para.refId
        else
            self._extRef = para.extRef

        fieldSpec =
            refId: self._refId
            fieldName: self._fieldName

        Meteor.autorun () ->
            Meteor.subscribe '_fields_data', fieldSpec, () ->
                self._ready = true
                unless self._id?
                    existing = Data.findOne({_refId: self._refId})
                    self._id = existing._id

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
