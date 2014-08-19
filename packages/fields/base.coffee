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
        if para.partOf?
            self._refId = para.partOf
        else
            self._refId = para.refId

        unless self._refId?
            throw new Meteor.Error 404, 'Invalid Field Initialization! Missing refId prop!'

        self.inputId = "#{self._fieldName}#{self._refId}input"

        console.log para

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
