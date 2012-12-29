define ["paper"], (paper) ->
    {Point, Raster, Size} = paper

    class Flyer
        onPath: yes
        minSpeed: 0.5
        minXVel: 0.1

        time: 0
        timeStep: 1 / 60
        remTime: 0

        upAcc: new Point 0, 1
        downAcc: new Point 0, 5

        constructor: (@path, imgId) ->
            @pos = @path.at(@path.start)
            @vel = new Point @minSpeed, 0
            @acc = @upAcc

            loadImg = =>
                @raster = new Raster(imgId)
                size = @raster.getSize().height

                if size > 128
                    @raster.setSize new Size(128, 128)
                    size = 128

                @raster.scale 1 / size
                @raster.rot = 0

            if $("##{imgId}")[0].complete
                loadImg()
            else
                $("##{imgId}").load loadImg

        _go: (dt) ->
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

            @pos

        go: (dt) ->
            dt += @remTime
            steps = 0

            while dt >= @timeStep
                @_go @timeStep
                dt -= @timeStep
                steps += 1

            # console.log steps, dt
            @remTime = dt

        draw: ->
            if @raster
                pos = @getPosition().add(@vel.rotate(-90).normalize(0.5))
                @raster.setPosition pos
                rot = @vel.angle - @raster.rot
                @raster.rotate rot
                @raster.rot += rot

        getPosition: ->
            @pos.add @vel.multiply(@remTime)

        upHandler: =>
            @acc = @upAcc

        downHandler: =>
            @acc = @downAcc

        setupControl: (el) ->
            $el = $(el)

            $el.on
                "mousedown touchstart": @downHandler
                "mouseup touchend": @upHandler

        finishControl: (el) ->
            $el = $(el)

            $el.off
                "mousedown touchstart": @downHandler
                "mouseup touchend": @upHandler

        getFunc: ->
            a = 1 / (2 * @vel.x * @vel.x)

            grad = @vel.y * (1 / @vel.x)

            b = grad - a * 2 * @pos.x


            c = @pos.y - a*@pos.x*@pos.x - b*@pos.x

            func: (x) -> a*x*x + b*x + c
            grad: (x) -> 2*a*x + b
