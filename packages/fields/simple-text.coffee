class Fields.TextField extends Fields._BaseField
    constructor: (para) ->
        super para

        @createEvents()

    createEvents: () ->
        self = @

        eventMap = {}
        eventMap["keyup .#{self.inputId}"] = (e) ->
            if self._events.beforeUpdate?
                self._events.beforeUpdate.call @, self, e

            self.update e.currentTarget.value

            if self._events.afterUpdate?
                self._events.afterUpdate.call @, self, e

        Template._field.events eventMap