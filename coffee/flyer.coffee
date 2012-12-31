define ["paper", "events", "jquery"], (paper, Events, $) ->
    {Point, Raster, Size} = paper

    class Flyer extends Events
        onPath: yes
        minSpeed: 1.5
        minXVel: 0.3

        time: 0
        clock: 0
        timeStep: 1 / 180
        remTime: 0

        upAcc: new Point 0, 5
        downAcc: new Point 0, 25

        lastMessage: null

        constructor: (@path, imgId) ->
            super()

            @pos = @path.at(@path.start)
            @vel = new Point @minSpeed, 0
            @acc = @upAcc

            @time = 0
            @clock = 0
            @onPath = yes
            @remTime = 0
            @lastMessage = null

            loadImg = =>
                @raster = new Raster(imgId)
                size = @raster.getSize().height

                if size > 128
                    @raster.setSize new Size(128, 128)
                    size = 128

                @raster.scale 1 / size
                @raster.rot = 0
                @draw()

            src = $("##{imgId}").attr('src')
            @progress = $("<img class='progress' src='#{src}'>")
            $('#progress').append @progress

            if $("##{imgId}")[0].complete
                loadImg()
            else
                $("##{imgId}").load loadImg

        _go: ->
            dt = @timeStep
            @vel = @vel.add @acc.multiply(dt)

            @vel.x = Math.max @vel.x, @minXVel

            if @vel.getLength() < @minSpeed
                @vel = @vel.normalize @minSpeed
            
            if @onPath
                pathGrad = @path.grad(@pos.x)

                if pathGrad.getDirectedAngle(@vel) < 0
                    # Jumping off path
                    @onPath = no
                else
                    # Staying on path
                    @vel = pathGrad.normalize @vel.getLength()
                    @pos = @path.at(@pos.add(@vel.multiply(dt)).x)
            if not @onPath
                firstX = @pos.x
                @pos = @pos.add @vel.multiply(dt)

                func = @getFunc()
                intersection = @path.intersect(func.func, func.grad, firstX, @pos.x, 0.01)

                if @pos.y > @path.at(@pos.x).y
                    # If path collision
                    grad = new Point(1, func.grad(intersection)).normalize()
                    pathGrad = @path.grad(intersection)
                    if grad.getAngle(pathGrad) < 90
                        @vel = @vel.project @path.grad(@pos.x)
                    else
                        @vel = new Point(0, 0)
                    @pos = @path.at @pos.x
                    @onPath = yes

            @clock += 1
            @time = @clock * @timeStep

            if @pos.x >= @path.end
                @finish()

            @pos

        go: (dt) ->
            dt += @remTime
            steps = Math.floor(dt / @timeStep)

            for i in [0...steps] by 1
                @_go()

            # console.log steps, dt
            @remTime = dt % @timeStep
            @time += @remTime

            if @lastMessage? and not @lastMessage.done and @lastMessage.time < @time
                console.log "Running postponed message", @lastMessage
                @_doMessage @lastMessage

        goto: (time) ->
            @go time - @time

        finish: ->
            if not @finished
                @trigger "finish", @time
                @finished = true

        draw: ->
            if @raster
                pos = @getPosition().add(@vel.rotate(-90).normalize(0.5))
                @raster.setPosition pos
                rot = @vel.angle - @raster.rot
                @raster.rotate rot
                @raster.rot += rot

            perc = (@pos.x - @path.start) * 100 / (@path.end - @path.start)

            @progress.css 'left', "#{perc}%"

        getPosition: ->
            @pos.add @vel.multiply(@remTime)

        upHandler: (e) =>
            e.preventDefault()
            @acc = @upAcc
            @trigger "msg",
                state: "up"
                pos: @pos
                vel: @vel
                time: @time
                onPath: @onPath

        downHandler: (e) =>
            e.preventDefault()
            @acc = @downAcc
            @trigger "msg",
                state: "down"
                pos: @pos
                vel: @vel
                time: @time
                onPath: @onPath

        _doMessage: (msg) ->
            msg.done = true

            @pos = new Point(msg.pos.x, msg.pos.y)
            @vel = new Point(msg.vel.x, msg.vel.y)
            @onPath = msg.onPath

            if msg.state is "down"
                @acc = @downAcc
            else
                @acc = @upAcc

            gotoTime = @time
            @time = msg.time
            @clock = Math.floor @time / @timeStep
            @remTime = @time % @timeStep

            @goto gotoTime

            console.log "Time before:", gotoTime, "Msg:", msg.time, "Now:", @time

        receive: (msg) ->
            if not @lastMessage or @lastMessage.time < msg.time
                if msg.time < @time
                    @_doMessage msg
                else
                    console.log "Postponed message. Time:", @time, "Message:", msg
                @lastMessage = msg
            else
                console.log "Out of order messages.", @lastMessage, msg

        setupControl: (el) ->
            $el = $(el)

            $el.on
                "mousedown touchstart keydown": @downHandler
                "mouseup touchend keyup": @upHandler

        finishControl: (el) ->
            $el = $(el)

            $el.off
                "mousedown touchstart keydown": @downHandler
                "mouseup touchend keyup": @upHandler

        remove: ->
            @raster.remove()
            @progress.remove()

        getFunc: ->
            a = 1 / (2 * @vel.x * @vel.x)

            grad = @vel.y * (1 / @vel.x)

            b = grad - a * 2 * @pos.x


            c = @pos.y - a*@pos.x*@pos.x - b*@pos.x

            func: (x) -> a*x*x + b*x + c
            grad: (x) -> 2*a*x + b
