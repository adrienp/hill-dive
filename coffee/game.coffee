define ["jquery", "underscore", "flyer", "randpath"], ($, _, Flyer, RandPath) ->
    
    class Game
        flyerImages: ["blue", "yellow", "red", "green"]

        results: {}
        flyers: {}
        users: {}
        numUsers: 0

        time: 0
        count: 0

        going: false

        constructor: (@gid, @user, data, @channel, @canvas) ->
            @results = {}
            @flyers = {}
            @users = {}
            @numUsers = 0
            @time = 0
            @count = 0
            @going = false

            if data instanceof RandPath
                @path = data
            else
                @path = new RandPath data.yvals, data.left, data.freq, data.step

            @me = new Flyer @path, @flyerImages[0]
            @flyers[@user.uid] = @me
            @numUsers += 1

            @users[@user.uid] = @user

            @me.on "msg", @meMsg
            @me.on "finish", @meFinish

            @me.setupControl window

            @channel.on "start", @start
            @channel.on "fly", @otherFly
            @channel.on "finish", @otherFinish
            @channel.on "done", @done

            @canvas.path = @path
            @canvas.focus = @me

            @going = false

            @canvas.view.setOnFrame @onFrame

            @canvas.draw()

        onFrame: (e) =>
            if @going
                for uid, flyer of @flyers
                    flyer.go Math.min(e.delta, 5)
                    flyer.draw()

            @canvas.draw()

            @count += 1
            @time += e.delta

            if @time > 1
                fps = Math.round(@count * 10 / @time) / 10
                $('#fps').html fps + " fps"
                @count = 0
                @time = 0

        addFlyer: (user) ->
            @users[user.uid] = user

            flyer = new Flyer @path, @flyerImages[@numUsers % @flyerImages.length]

            @flyers[user.uid] = flyer

            @numUsers += 1

        start: =>
            @going = true
            $('#panel').hide()

        meMsg: (msg) =>
            if @going
                url = "/games/#{@gid}/#{@user.uid}"
                console.log "Posting", msg, "to", url
                $.post url,
                    msg: JSON.stringify(msg)

        meFinish: (time) =>
            console.trace()
            url = "/games/#{@gid}/#{@user.uid}/finish"
            console.log "Posting finish", time, "to", url
            $.post url,
                time: time
            @canvas.focus = null
            @results[@user.uid] =
                name: @user.name
                time: time

            $('#panel > div').removeClass 'current'
            $('#results').addClass 'current'
            @renderResults()
            $('#panel').show()
            @me.off "msg", @meMsg
            @me.off "finish", @meFinish

        renderResults: ->
            results = _.sortBy (v for k, v of @results),
                (result) -> result.time

            $('#result-list').empty()

            for result in results
                time = Math.round(result.time * 10) / 10
                $('#result-list').append "<li>#{result.name}: #{time} s</li>"

        otherFly: (msg) =>
            @flyers[msg.uid].receive msg.msg

        otherFinish: (msg) =>
            @results[msg.uid] =
                name: @users[msg.uid].name
                time: msg.time

            @renderResults()

        done: (msg) =>
            console.log "Done"
            @results = {}

            for uid, time of msg.results
                @results[uid] =
                    name: @users[uid].name
                    time: time

            @renderResults()
            @canvas.view.setOnFrame null

            for uid, flyer of @flyers
                flyer.remove()

            @path.remove()
            @canvas.clear()
            @canvas.view.draw()
            @me.finishControl window

            @channel.off "start", @start
            @channel.off "fly", @otherFly
            @channel.off "finish", @otherFinish
            @channel.off "done", @done
