define [], ->
    class Events
        constructor: ->
            @events = {}

        trigger: (eventType, msg = @) ->
            if eventType of @events
                (fn?(msg) for fn in @events[eventType])

        on: (eventType, fn) ->
            if eventType not of @events
                @events[eventType] = []

            @events[eventType].push fn

        off: (eventType, fn = null) ->
            if fn
                i = @events[eventType]?.indexOf fn

                if i? >= 0
                    @events[eventType].splice(i, 1)
            else
                delete @events[eventType]