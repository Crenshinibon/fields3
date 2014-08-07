class Fields.TextField extends Fields._BaseField
    constructor: (para) -> 
        super(para)
        
        @createEvents()
        
    createEvents: () ->
        self = @
        
        eventMap = {}

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
            
        if @_events?.update?
            dispatchEvents @_events.update, 'keyup', ".#{self.inputId}",  (e, field) ->
                field.update e.currentTarget.value
        else
            eventMap["keyup .#{self.inputId}"] = (e) ->
                self.update e.currentTarget.value

        if @_events?.save?
            dispatchEvents @_events.save, 'click', ".#{self.saveId}", (e, field) ->
                field.save()
        else
            eventMap["click .#{self.saveId}"] = (e) ->
                self.save()

        if @_events?.discard?
            dispatchEvents @_events.discard, 'click', ".#{self.discardId}", (e, field) ->
                field.discard()
        else
            eventMap["click .#{self.discardId}"] = (e) ->
                self.discard()
            
        _registerFieldEvents eventMap
        