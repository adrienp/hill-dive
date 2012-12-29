define ["paper", "jquery"], (paper, $) ->
    {Path, Point, Matrix, Raster, Size, Group, Layer, Gradient, GradientColor} = paper
    
    class Canvas
        constructor: (canvasId) ->
            paper.setup canvasId
            @view = paper.view

            @$window = $(window)

            @sky = new Path.Rectangle(new Point(0, 0), new Point(1, 1))
            grad = new Gradient(["#AADAFA", "#027ED1"])
            grad = new GradientColor(grad, new Point(0, 0), new Point(0, 1))
            @sky.fillColor = grad

            @resize()
            @$window.resize @resize

            @view.draw()

            window.v = @view

        resize: =>
            windowSize = new Point(@$window.width() - 4, @$window.height() - 4)
            @view.setViewSize windowSize

            @draw()

        setFrame: (x, xPerc, bottom, top) ->
            # bounds = @view.getBounds()
            height = @view.getViewSize().getHeight()
            @view.setZoom(height / (bottom - top))

            width = @view.getBounds().width
            xPerc -= 0.5
            centerX = x - xPerc * width

            @view.setCenter(new Point(centerX, (top + bottom) / 2))

        showAll: ->
            if @path
                width = @view.getViewSize().getWidth()

                @view.setZoom width / (@path.end - @path.start)

                @view.setCenter new Point((@path.end + @path.start) / 2, (@path.range.bottom + @path.range.top) / 2)

        draw: ->
            if @focus
                focusPos = @focus.getPosition()
                top = Math.min(focusPos.y, @path.range.top)
                bottom = @path.range.bottom

                buffer = (bottom - top) * 0.3

                top -= buffer
                bottom += buffer

                @setFrame(focusPos.x, 0.15, bottom, top)
            else
                @showAll()

            bounds = @view.getBounds()

            @sky.segments[0].setPoint new Point(bounds.x, bounds.y)
            @sky.segments[1].setPoint new Point(bounds.x + bounds.width, bounds.y)
            @sky.segments[2].setPoint new Point(bounds.x + bounds.width, bounds.y + bounds.height)
            @sky.segments[3].setPoint new Point(bounds.x, bounds.y + bounds.height)

            grad = new Gradient(["#AADAFA", "#027ED1"])
            grad = new GradientColor(grad, new Point(0, bounds.y), new Point(0, bounds.y + bounds.height))
            @sky.fillColor = grad
