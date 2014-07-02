UI.registerHelper 'field', (para) ->
    Template._field
    
Template._field._context = () ->
    @

@_registerEvents = (eventMap) ->
    Template._field.events eventMap    