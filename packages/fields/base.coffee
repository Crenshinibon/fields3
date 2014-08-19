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

        _init = () ->
            self.inputId = "#{self._fieldName}#{self._id}input"
            fieldSpec =
                id: self._id
                extRef: self._extRef
                fieldName: self._fieldName
            Meteor.autorun () ->
                Meteor.subscribe '_fields_data', fieldSpec, () ->
                    self._ready = true
                    self._loadDeps.changed()

        unless self._id?
            Meteor.call '_fields_find_field_by_extRef', para, (error, result) ->
                unless error?
                    self._id = result
                    _init()
        else
            _init()


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
