class Fields.TextField extends Fields._BaseField
    constructor: (para) -> 
        super(para)
        
        @createEvents()
        
    createEvents: () ->
        self = @
        
        eventMap = {}
        updFun = (e, field) ->
            field.update e.currentTarget.value
        saveFun = (e, field) ->
            field.save()
        discFun = (e, field) ->
            field.discard()
        
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
                    event.callback.call @, e, self
            else
                eventMap[key] = (e) ->
                    defaultFun.call @, e, self
            
        
        if @_events?
            dispatchEvents @_events.update, 'keyup', ".#{self.inputId}", updFun
            dispatchEvents @_events.save, 'click', ".#{self.saveId}", saveFun
            dispatchEvents @_events.discard, 'click', ".#{self.discardId}", discFun
        else
            eventMap["keyup .#{self.inputId}"] = (e) ->
                updFun.call @, e, self
            eventMap["click .#{self.saveId}"] = (e) ->
                saveFun.call @, e, self
            eventMap["click .#{self.discardId}"] = (e) ->
                discFun.call @, e, self
            
        _registerFieldEvents eventMap
        