@Movies = new Meteor.Collection 'movies'

if Meteor.isServer
    Meteor.publish 'movies', () ->
        Movies.find {}
    
    Movies.allow
        insert: (userId, doc) ->
            false
        update: (userId, doc, fieldNames, modifier) ->
            true
        remove: (userId, doc) ->
            true

    Meteor.methods
        'create_movie': () ->
            Movies.insert {}
    
            
if Meteor.isClient

    Meteor.subscribe 'movies'

    UI.body.events
        'click .add-movie': () ->
            Meteor.call 'create_movie'
    
    Template.viewContent.helpers
        movies: () ->
            Movies.find {}
        name: () ->
            new Fields.TextField
                fieldName: 'name'
                form: 'movie'
                extRef: @_id

    Template.editContent.helpers
        movies: () ->
            Movies.find {}
        name: () ->
            new Fields.TextField
                fieldName: 'name'
                form: 'movie'
                extRef: @_id
        tagline: () ->
            new Fields.TextField
                fieldName: 'tagline'
                form: 'movie'
                extRef: @_id

    Template.actorsList.helpers
        actors: () ->
            self = @
            new Fields.List
                base: self._id,
                listName: 'actors'

    Template.actor.helpers
        actorName: () ->
            self = @
            new Fields.TextField
                fieldName: 'actorName'
                listContext: self

        actorCountry: () ->
            self = @
            new Fields.TextField
                fieldName: 'actorCountry'
                listContext: self

