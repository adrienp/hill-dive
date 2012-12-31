define ["goog", "jquery", "events"], (goog, $, Events) ->

    class Channel extends Events
        constructor: (name, success) ->
            super()

            $.post '/connect',
                name: name,
                (resp) =>
                    if resp.success
                        @user = resp
                        token = resp.token
                        uid = resp.uid

                        @channel = new goog.appengine.Channel(token)
                        @socket = @channel.open()

                        @socket.onopen = ->
                            console.log "Socket Opened:", uid

                        @socket.onmessage = (msg) =>
                            msg = JSON.parse msg.data
                            console.log "Message:", msg
                            @trigger msg.type, msg

                        @socket.onerror = (e) ->
                            console.error e.code + ": " + e.description

                        @socket.onclose = ->
                            console.log "Socket Closed"

                        if success
                            success @user
                    else
                        console.error "Can't connect", resp

