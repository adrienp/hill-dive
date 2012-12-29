define ["goog", "jquery"], (goog, $) ->

    class Channel
        constructor: (name) ->
            @events = {}

            $.post '/connect',
                name: name,
                (resp) =>
                    if resp.success
                        @token = resp.token
                        @uid = resp.uid

                        @channel = new goog.appengine.Channel(token)
                        @socket = @channel.open()

                        @socket.onopen = ->
                            console.log "Socket Opened:", uid

                        @socket.onmessage = (msg) =>
                            msg = JSON.parse msg.data
                            @trigger msg.type, msg

                        @socket.onerror = (e) ->
                            console.error e.code + ": " + e.description

                        @socket.onclose = ->
                            console.log "Socket Closed"

        trigger: (eventType, msg) ->
            if eventType of @events
                (fn(msg) for fn in @events[eventType])

        on: (eventType, fn) ->
            if eventType not of @events
                @events[eventType] = []

            @events[eventType].push fn

        off: (eventType, fn) ->
            i = @events[eventType]?.indexOf fn

            if i? >= 0
                @events[eventType].splice(i, 1)