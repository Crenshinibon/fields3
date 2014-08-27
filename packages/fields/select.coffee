class Fields.Select extends Fields._BaseField
    constructor: (para) ->
        super para

        self = @
        Meteor.autorun (comp) ->
            if self.ready()
                comp.stop()
                self._initOptions para.optionsSource


    _initOptions: (os) ->
        self = @
        options = os.fetch()
        currentValue = self.value()

        console.log 'current', options, currentValue

        optionObjects = []
        options.forEach (e) ->
            console.log 'option', e
            optionName = currentValue
            for attr of e
                if attr.slice(0,1) isnt '_'
                    optionName = e[attr]
                    break

            console.log 'optName', optionName

            if optionName?
                optionObject = {}
                optionObject.option = optionName

                if optionName is currentValue
                    optionObject.selected = 'selected'

                optionObjects.push optionObject

        console.log 'optObjects', optionObjects
        self._localData.set 'options', optionObjects

    options: () ->
        @_localData.get 'options'