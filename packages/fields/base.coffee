class Fields._BaseField
    constructor: (para) ->
        self = @
        self._events = {beforeUpdate: null, afterUpdate: null}
        self._events.beforeUpdate = para.events?.beforeUpdate
        self._events.afterUpdate = para.events?.afterUpdate

        self._collection = Fields._getCollection para.form
        self._para = para

        if self._para.id?
            self.inputId = "#{self._para.fieldName}#{self._para.id}input"
        else
            self.inputId = "ext#{self._para.fieldName}#{self._para.extRef}input"

        self._subscribe()

    _subscribe: () ->
        self = @
        if self._para.id?
            self._subHandle = Meteor.subscribe '_fields_form_field', self._para, () ->
                unless self._para.extRef?
                    f = self._collection.findOne {_id: self._para.id}
                    self._para.extRef = f._extRef
        else
            self._subHandle = Meteor.subscribe '_fields_form_field_byExtRef', self._para, () ->

                f = self._collection.findOne {_extRef: self._para.extRef}
                self._para.id = f._id

                @stop()
                #resubscribe by id, might be unnecessary
                self._subscribe()


    loading: () ->
        !@ready()
    
    ready: () ->
        @_subHandle.ready

    value: () ->
        self = @
        
        value = '...loading...'
        if self.ready()
            d = self._collection.findOne {_id: self._para.id}
            if d?
                value = d[self._para.fieldName]
                unless value?
                    value = ''
            else
                value = ''
        
        value

    update: (newValue) ->
        self = @

        val = {}
        val[self._para.fieldName] = newValue

        self._collection.update {_id: self._para.id}, {$set: val}

    #override this function in concrete implementations
    createEvents: () ->
