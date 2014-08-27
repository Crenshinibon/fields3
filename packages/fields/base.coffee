class Fields._BaseField
    constructor: (para) ->
        self = @

        self._localData = new ReactiveDict
        self._localData.set 'ready', false

        if para.listContext?
            self._para =
                events: para.events
                id: para.listContext._id
                form: para.listContext._form
                index: para.listContext._index
                fieldName: para.fieldName
                listContext: para.listContext
        else
            self._para = para

        self._events = {beforeUpdate: null, afterUpdate: null}
        self._events.beforeUpdate = self._para.events?.beforeUpdate
        self._events.afterUpdate = self._para.events?.afterUpdate

        self._collection = Fields._getCollection self._para.form

        self._baseUIID = Random.id()
        self.fieldName = self._para.fieldName
        self.inputId = "#{self._para.fieldName}#{self._baseUIID}input"

        self._subscribe()

    _subscribe: () =>
        self = @

        if self._para.id?
            Meteor.subscribe '_fields_form_field', self._para, () ->
                unless self._para.extRef?
                    f = self._collection.findOne {_id: self._para.id}
                    self._para.extRef = f._extRef

                self._localData.set 'ready', true
        else
            Meteor.subscribe '_fields_form_field_byExtRef', self._para, () ->

                f = self._collection.findOne {_extRef: self._para.extRef}
                self._para.id = f._id

                @stop()
                #resubscribe by id, might be unnecessary
                self._subscribe()


    loading: () =>
        not @ready()
    
    ready: () =>
        @_localData.get 'ready'

    docId: () =>
        @_para.id

    value: () =>
        self = @
        
        value = '...loading...'
        if self.ready()
            d = self._collection.findOne {_id: self.docId()}

            if d?
                value = d[self._para.fieldName]
                unless value?
                    value = ''
            else
                value = ''
        
        value

    update: (newValue) =>
        self = @

        val = {}
        val[self._para.fieldName] = newValue

        self._collection.update {_id: self._para.id}, {$set: val}

