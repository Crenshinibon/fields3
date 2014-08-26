Fields.currentValues = (form, extRef) ->
    col = Fields._getCollection form

    base = col.findOne {_extRef: extRef}
    data = _separateMeta base

    _lists extRef, data

    console.log data
    data


_separateMeta = (object) ->
    data = {}
    data._meta = {}

    for prop of object
        if prop.slice(0,1) is '_'
            data._meta[prop] = object[prop]
        else
            data[prop] = object[prop]
    data


_lists = (parentId, data) ->
    col = Fields._getCollection parentId
    cur = col.find {}, {sort: {_index: 1}}

    cur.forEach (e) ->
        unless data[e._listName]?
            data[e._listName] = []

        obj = _separateMeta(e)
        _lists e._id, obj

        data[e._listName].push obj

    data