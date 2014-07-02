@Unsaved = {}
@Unsaved.collection = new Meteor.Collection null

_fieldId = (name, refId) ->
    "#{name}-#{refId}"

_exists = (fId) ->
    exists = Unsaved.collection.findOne {fieldId: fId}
    exists?
    
@Unsaved.dirty = (name, refId) ->
    fId = _fieldId name, refId
    _exists fId
    
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
    