Fields = {}
@Fields = Fields


class Fields.TextField
    _ready: false
    
    
    #events spec
    #
    # save:
    #   type: 'click'
    #   selector: '.save_button'
    #   callback: (e) ->
    #        @save()
    # update: 
    #   type: 'keyup'
    #   selector: undefined
    # discard: 
    #   type: 'click'
    #   selector: '.discard_button'
    #
    
    constructor: (@_name, @_refId, _events) ->
        self = @
        self._loadDeps = new Deps.Dependency
        self._valueDeps = new Deps.Dependency
        self.saveId = "#{@_name}#{@_refId}save"
        self.inputId = "#{@_name}#{@_refId}input"
        self.discardId = "#{@_name}#{@_refId}discard"
        
        eventMap = {}
        updFun = (e) ->
            @update e.currentTarget.value
        saveFun = (e) ->
            @save()
        discFun = (e) ->
            @discard()
        
        dispatchEvents = (event, defaultType, defaultSelector, defaultFun) ->
            unless event?
                event = {}
                
            key = ""
            if event.type?
                key += "#{event.type} "
            else
                key += "#{defaultType} "
            
            if event.selector?
                key += event.selector
            else
                key += defaultSelector
            
            if event.callback?
                eventMap[key] = (e) ->
                    event.callback.call self, e
            else
                eventMap[key] = (e) ->
                    defaultFun.call self, e
            
        
        if _events?
            dispatchEvents _events.update, 'keyup', ".#{self.inputId}", updFun
            dispatchEvents _events.save, 'click', ".#{self.saveId}", saveFun
            dispatchEvents _events.discard, 'click', ".#{self.discardId}", discFun
        else
            eventMap["keyup .#{self.inputId}"] = (e) ->
                updFun.call self, e
            eventMap["click .#{self.saveId}"] = (e) ->
                saveFun.call self, e
            eventMap["click .#{self.discardId}"] = (e) ->
                discFun.call self, e
            
        _registerEvents eventMap
            
        Meteor.autorun () ->
            Meteor.subscribe '_fields_data', self._refId, self._name, () ->
                self._ready = true
                self._id = Data.findOne({refId: self._refId})._id
                self._loadDeps.changed()
                
    
    loading: () ->
        !@ready()
    
    ready: () ->
        @_loadDeps.depend()
        @_ready
    
    dirty: () ->
        @_valueDeps.depend()
        d = Unsaved.dirty @_name, @_refId
        d
    
    value: () ->
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
        
        console.log value, self
        value
        
    update: (newValue) ->
        Unsaved.set @_name, @_refId, newValue
        @_valueDeps.changed()
    
    save: () ->
        self = @
        console.log self
        if self.dirty()
            value = Unsaved.get self._name, self._refId
            
            val = {}
            val[self._name] = value
            
            Data.update {_id: self._id}, {$set: val}
            
            Unsaved.reset self._name, self._refId
            self._valueDeps.changed()
        
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
    