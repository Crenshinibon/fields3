@Movies = new Meteor.Collection 'movies'
@Actors = new Meteor.Collection 'actors'

if Meteor.isServer
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

    Meteor.subscribe 'movies'
    Meteor.subscribe 'actors'
    
    UI.body.events
        'click .add-movie': () ->
            Movies.insert {actors: []}
    
    Template.viewContent.movies = () ->
        Movies.find {}
    
    Template.viewContent.name = () ->
        new Fields.TextField
            fieldName: 'name'
            form: 'movie'
            extRef: @_id

    Template.editContent.movies = () ->
        Movies.find {}

    Template.editContent.name = () ->
        new Fields.TextField
            fieldName: 'name'
            form: 'movie'
            extRef: @_id

    Template.editContent.tagline = () ->
        new Fields.TextField
            fieldName: 'tagline'
            form: 'movie'
            extRef: @_id

    Template.actorsList.actors = () ->
        self = @

        list = new Fields.List
            base: self._id,
            extItems: self.actors

        list.onAppend () ->
            id = Actors.insert {}
            Movies.update {_id: self._id}, {$push: {actors: id}}
            id

        #list.onRemove (element, pos) ->
        #    Actors.remove {_id: element._id}
        #    Movies.update {_id: self._id}, {$pull: {actors: element._id}}

        #list.sortBy
        #    field: 'actorName'
        #    dir: 1

        list


    Template.actorsList.actorName = () ->
        self = @
        new Fields.TextField
            fieldName: 'actorName'
            listContext: self

    Template.actorsList.actorCountry = () ->
        self = @
        new Fields.TextField
            fieldName: 'actorCountry'
            listContext: self
