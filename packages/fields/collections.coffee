@Data = new Meteor.Collection 'fields_data'
@Changes = new Meteor.Collection 'fields_changes'


if Meteor.isServer
    Meteor.publish '_fields_data', (refId, field) ->
        fieldSelector = {}
        fieldSelector.refId = 1
        fieldSelector[field] = 1
        existing = Data.find {refId: refId}, {fields: fieldSelector}
        
        if existing.count() is 0
            #setup new field with empty string value
            newField = 
                refId: refId
            newField[field] = ''
            
            Data.insert newField
            existing = Data.find {refId: refId}, {fields: fieldSelector}
        
        existing
        
    Meteor.publish '_fields_all_data', (refId) ->
        Data.findOne {refId: refId}
    
    @Data.allow
        insert: () ->
            true 
        update: () ->
            true
        remove: () ->
            true
            
    @Changes.allow
        insert: () ->
            true
        update: () ->
            true
        remove: () ->
            true
    