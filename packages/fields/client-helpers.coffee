UI.registerHelper 'textField', () ->
    Template._textField
    
UI.registerHelper 'list', () ->
    Template._list

UI.registerHelper 'textArea', () ->
    Template._textArea

UI.registerHelper 'select', () ->
    Template._select

Template._textArea.rendered = () ->
    ta = @data
    inputId = ta.inputId
    clazz = ".#{inputId}"
    ele = $ clazz
    ele.wysiwyg
        toolbarSelector: ".#{ta.toolbarId}"

Template._textArea.events
    'input div': (e) ->
        newValue = $(e.currentTarget).cleanHtml()

        @markChange newValue

Template._textField.events
    'input input': (e) ->
        field = @

        if field._events.beforeUpdate?
            field._events.beforeUpdate.call field, e

        field.update e.currentTarget.value

        if field._events.afterUpdate?
            field._events.afterUpdate.call field, e


Template._select.events
    'change select': (e) ->
        field = @
        newValue = e.currentTarget.value
        field.update newValue