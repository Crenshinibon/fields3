UI.registerHelper 'field', (para) ->
    Template._field
    
UI.registerHelper 'list', (para) ->
    Template._list

Template._field._context = () ->
    @

Template._list._context = () ->
    @


Template._field.rendered = () ->
    field = @data

    inst = @$("input").context
    #console.log inst, field.inputId

    @$(".#{field.inputId}").on 'keyup', (e) ->
        if field._events.beforeUpdate?
            field._events.beforeUpdate.call @, field, e

        console.log e
        field.update e.currentTarget.value

        if field._events.afterUpdate?
            field._events.afterUpdate.call @, field, e
