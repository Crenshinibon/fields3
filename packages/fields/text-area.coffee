class Fields.TextArea extends Fields._BaseField
    constructor: (para) ->
        super para

        self = @
        self.toolbarId = self._para.fieldName + self._baseUIID + 'toolbar'
        self._localData.set 'lastUpdated', (new Date).getTime()
        self._localData.set 'possibleChange', false



###
        self.storedValue = self.value

        Deps.autorun (comp) ->
            if self.ready()
                self._localData.set 'interimValue', self.storedValue()
                comp.stop()


    value: () ->
        self._localData.get 'interimValue'

###