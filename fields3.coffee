Movies = new Meteor.Collection 'movies'
Actors = new Meteor.Collection 'actors'

if Meteor.isServer
    console.log 'server test'
    
    Meteor.publish 'movies', () ->
        Movies.find {}
    
    Meteor.publish 'actors', () ->
        Actors.find {}    
    
    Movies.allow
        insert: (userId, doc) ->
            true
        update: (userId, doc, fieldNames, modifier) ->
            true
        remove: (userId, doc) ->
            true
            
    Actors.allow
        insert: (userId, doc) ->
            true
        update: (userId, doc, fieldNames, modifier) ->
            true
        remove: (userId, doc) ->
            true
    
            
if Meteor.isClient
    
    Meteor.autorun () ->
        Meteor.subscribe 'movies'
        Meteor.subscribe 'actors'
    
    UI.body.events
        'click .add-movie': (e) ->
            Movies.insert {} 
    
    Template.viewContent.movies = () ->
        Movies.find {}
    
    Template.viewContent.name = () ->
        new Fields.TextField 'name', @_id
        
    Template.editContent.movies = () ->
        Movies.find {}
        
    Template.editContent.actors = () ->
        self = @
        list = new Fields.List 
            name: 'actors' 
            refId: self._id, 
            items: Actors.find({movieId: self._id}).fetch()
        
        list.registerCallbacks
            #in case of external ref object, must return new element id.
            append: (event) ->
                Actors.insert {movieId: self._id}
            prepend: (event) ->
                Actors.insert {movieId: self._id}
            insert: (event) ->
                Actors.insert {movieId: self._id}
            remove: (event, element, pos) ->
                Actors.remove {_id: element._id}
            move: (event, element, oldPos, newPos) ->
        
        #list.sortBy
        #    field: 'actorName'
        #    dir: 1
        #list
        
    Template.editContent.name = () ->
        new Fields.TextField 
            name: 'name'
            refId: @_id