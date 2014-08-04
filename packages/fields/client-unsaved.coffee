@Unsaved = {}
@Unsaved.collection = new Meteor.Collection null

_fieldId = (name, refId) ->
    "#{name}-#{refId}"

_exists = (fId) ->
    exists = Unsaved.collection.findOne {fieldId: fId}
    exists?


_notEqual = (val1, val2) ->
    if _isArray(val1) and _isArray(val2)
        _unEqualArray val1, val2
    else
        val1 isnt val2

_unEqualArray = (ar1, ar2) ->
    if ar1.length isnt ar2.length
        return true
    
    for e, i in ar1
        if e isnt ar2[i]
            return true
    false

_isArray = (value) ->
    value? and (Array.isArray(value) || {}.toString.call(value) is '[object Array]')

@Unsaved.dirty = (name, refId) ->
    fId = _fieldId name, refId
    uns = Unsaved.collection.findOne {fieldId: fId}
    unless uns?
        return false
    
    cur = Data.findOne {refId: refId}
    unless cur?
        return true
    
    unsavedVal = uns.value
    currentVal = cur[name]
    _notEqual(unsavedVal, currentVal)
    
@Unsaved.get = (name, refId) ->
    fId = _fieldId name, refId
    d = Unsaved.collection.findOne {fieldId: fId}
    d.value
    
@Unsaved.set = (name, refId, value) ->
    fId = _fieldId name, refId
    if _exists fId
        Unsaved.collection.update {fieldId: fId}, {$set: {value: value}}
    else
        Unsaved.collection.insert {fieldId: fId, value: value}
    
@Unsaved.reset = (name, refId) ->
    fId = _fieldId name, refId
    Unsaved.collection.remove {fieldId: fId}
    