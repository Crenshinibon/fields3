class Fields.TextArea extends Fields._BaseField
    constructor: (para) ->
        super para

        self = @
        self.toolbarId = self._para.fieldName + self._baseUIID + 'toolbar'
        self._localData.set 'lastUpdated', (new Date).getTime()
        self._localData.set 'possibleChange', undefined

        #non-reactive var
        self._interimValue = '...loading...'

        Meteor.autorun (comp) ->
            if self.ready()
                self._interimValue = self.value()
                comp.stop()


        #TODO tune the timers
        _update = () ->
            lastUpdate = self._localData.get 'lastUpdated'
            pChange = self._localData.get 'possibleChange'

            now = (new Date).getTime()
            diff = now - lastUpdate

            if (diff > 2000) and pChange?
                self._localData.set 'lastUpdated', now
                self._localData.set 'possibleChange', undefined

                self.update pChange

        Meteor.setInterval _update, 500

    valueSnapshot: () =>
        @_interimValue

    markChange: (newValue) =>
        self = @
        self._localData.set 'possibleChange', newValue

    stalling: () =>
        self = @
        lastUpdate = self._localData.get 'lastUpdated'
        pChange = self._localData.get 'possibleChange'

        now = (new Date).getTime()
        diff = now - lastUpdate

        pChange? and (diff < 2000)