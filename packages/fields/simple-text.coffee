class Fields.TextField extends Fields._BaseField
    constructor: (para) ->
        super para

    #it's a hook called from base after connecting
    createEvents: () ->
        self = @

        eventMap = {}
        eventMap["keyup .#{self.inputId}"] = (e) ->
            if self._events.beforeUpdate?
                self._events.beforeUpdate.call @, self, e

            console.log 'event fired', e
            self.update e.currentTarget.value

            if self._events.afterUpdate?
                self._events.afterUpdate.call @, self, e

        Template._field.events eventMap