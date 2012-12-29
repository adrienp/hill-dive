define ["paper", "underscore", "util"], (paper, _, util) ->
    {Point, Gradient, GradientColor} = paper

    class Path
        constructor: (@func, @gradFunc, @start, @end, @step) ->
            @at = (x) -> new Point(x, @func(x))
            @grad = (x) -> new Point(1, @gradFunc(x)).normalize()
            @range = @_range(@start, @end)

            grad = new Gradient(["#98FA37", "#2A8000"])
            grad = new GradientColor(grad, new Point(0, @range.top), new Point(0, @range.bottom + @range.span))

            @drawPath = new paper.Path()
            @drawPath._hill = true
            @drawPath.strokeColor = 'black'
            @drawPath.strokeWidth = 0.05
            @drawPath.fillColor = grad
            @drawPath.addSegments(@getPoints())

        getPoints: ->
            (@at(x) for x in _.range(@start, @end + @step, @step))

        getGradPoints: ->
            (new Point(x, @gradFunc(x)) for x in _.range(@start, @end + @step, @step))

        _range: (left, right) ->
            # Compute the y-range within the bounds
            leftY = @func(left)
            ret =
                top: leftY
                bottom: leftY

            for x in [left...right] by @step
                y = @func(x)

                if y < ret.top
                    ret.top = y
                if y > ret.bottom
                    ret.bottom = y

            ret.span = ret.bottom - ret.top

            ret

        intersect: (func, grad, leftBound, rightBound, error = null) ->
            # Use Newton's Method to find intersection
            intFunc = (x) => func(x) - @func(x)
            intGrad = (x) => grad(x) - @gradFunc(x)

            leftDif = intFunc(leftBound)
            rightDif = intFunc(rightBound)

            if (leftDif > 0 and rightDif > 0) or (leftDif < 0 and rightDif < 0)
                return null

            x = (rightBound + leftBound) / 2
            error = error or @step / 2

            while Math.abs(intFunc(x)) > error
                x = x - intFunc(x) / intGrad(x)

            x
