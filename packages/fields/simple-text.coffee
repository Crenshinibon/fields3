class Fields.TextField extends Fields._BaseField
    constructor: (para) ->
        super para

        @_createEvents()

    _createEvents: () =>
        self = @


###
eventMap = {}
eventMap["keyup .#{self.inputId}"] = (e) ->

    if self._events.beforeUpdate?
        self._events.beforeUpdate.call @, self, e

    if self._para.listContext?
        console.log eventMap, self

    self.update e.currentTarget.value

    if self._events.afterUpdate?
        self._events.afterUpdate.call @, self, e

eventMap["click .#{self.inputId}"] = (e) ->
    console.log 'test', e


#UI.body.events eventMap

Template._field.events eventMap
###