Fields = {}
@Fields = Fields


class Fields._BaseField
    _ready: false
    
    #para spec
    # name: 'named identifier for ref. object'
    # refId: 'external reference object'
    # partOf: 'optional parent container'
    # events: eventSpec
    #
    #events spec
    #
    # save:
    #   type: 'click'
    #   selector: '.save_button'
    #   callback: (e, field) ->
    #        field.save()
    # update: 
    #   type: 'keyup'
    #   selector: undefined
    # discard: 
    #   type: 'click'
    #   selector: '.discard_button'
    #
    
    constructor: (para) ->
        self = @
        
        self._name = para.name
        self._refId = para.refId

        self._partOf = para.partOf
        unless self._partOf?
            self._extRef = para.refId

        self._events = para.events
        
        self._loadDeps = new Deps.Dependency
        self._valueDeps = new Deps.Dependency
        self.saveId = "#{@_name}#{@_refId}save"
        self.inputId = "#{@_name}#{@_refId}input"
        self.discardId = "#{@_name}#{@_refId}discard"
        
        Meteor.autorun () ->
            Meteor.subscribe '_fields_data', self._refId, self._name, () ->
                self._ready = true
                self._id = Data.findOne({refId: self._refId})._id
                self._loadDeps.changed()

                if para.isReady? and para.isReady? and para.isReady.length > 0
                    para.isReady.forEach (e) ->
                        e.call self

    loading: () ->
        !@ready()
    
    ready: () ->
        @_loadDeps.depend()
        @_ready
    
    dirty: () ->
        @_valueDeps.depend()
        d = Unsaved.dirty @_name, @_refId
        d
        
    unsavedValue: () ->
        @_valueDeps.depend()
        
        value = '...loading...'
        self = @
        if self.ready()
            if self.dirty()
                value = Unsaved.get self._name, self._refId
            else
                d = Data.findOne self._id
                if d?
                    value = d[self._name]
                else
                    value = ''
        value
        
    value: () ->
        self = @
        
        self._valueDeps.depend()
        value = '...loading...'
        if self.ready()
            d = Data.findOne self._id
            if d?
                value = d[self._name]
                unless value?
                    value = ''
            else
                value = ''
        
        value
        
    update: (newValue) ->
        Unsaved.set @_name, @_refId, newValue
        @_valueDeps.changed()
    
    save: () ->
        self = @
        if self.dirty()
            value = Unsaved.get self._name, self._refId
            
            val = {}
            val[self._name] = value
            
            Data.update {_id: self._id}, {$set: val}
            
            Unsaved.reset self._name, self._refId
            self._valueDeps.changed()

    _init: (value) ->
        self = @

        val = {}
        val[self._name] = value
        Data.update {_id: self._id}, {$set: val}
        
    discard: () ->
        Unsaved.reset @_name, @_refId
        @_valueDeps.changed()
        
    valid: () ->
        @_valueDeps.depend()
        true
    
    saveable: () ->
        @_valueDeps.depend()
        @valid() and @dirty()
    
    discardable: () ->
        @_valueDeps.depend()
        @dirty()
    
    
