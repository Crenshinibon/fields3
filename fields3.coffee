Movies = new Meteor.Collection 'movies'

if Meteor.isServer
    console.log 'server test'
    
    Meteor.publish 'movies', () ->
        Movies.find {}
        
    Movies.allow
        insert: (userId, doc) ->
            console.log userId, doc
            true
        update: (userId, doc, fieldNames, modifier) ->
            true
        remove: (userId, doc) ->
            true
            
if Meteor.isClient
    
    Meteor.autorun () ->
        Meteor.subscribe 'movies'
    
    UI.body.events
        'click .add-movie': (e) ->
            Movies.insert {} 
    
    Template.viewContent.movies = () ->
        Movies.find {}
    
    Template.viewContent.name = () ->
        new Fields.TextField 'name', @_id
        
    Template.editContent.movies = () ->
        Movies.find {}
    
    Template.editContent.name = () ->
        new Fields.TextField 'name', @_id