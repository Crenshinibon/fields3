UI.registerHelper 'textField', (para) ->
    Template._textField
    
UI.registerHelper 'list', (para) ->
    Template._list

UI.registerHelper 'textArea', (para) ->
    Template._textArea

Template._textField.events
    'keyup input': (e) ->
        field = @

        if field._events.beforeUpdate?
            field._events.beforeUpdate.call field, e

        field.update e.currentTarget.value

        if field._events.afterUpdate?
            field._events.afterUpdate.call field, e


