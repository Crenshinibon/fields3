UI.registerHelper 'field', (para) ->
    Template._field
    
UI.registerHelper 'list', (para) ->
    Template._list

Template._field._context = () ->
    @

Template._list._context = () ->
    @

