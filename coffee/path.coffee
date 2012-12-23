define ["paper", "underscore"], (paper, _) ->
	Point = paper.Point

	class Path
		constructor: (@at, @grad, @start, @end, @step) ->

		getPoints: ->
			(new Point(x, @at(x)) for x in _.range(@start, @end + @step, @step))

	class FuncPath extends Path
		constructor: (@func, @gradFunc, start, end, step) ->
			at = (x) -> new Point(x, @func(x))
			grad = (x) -> new Point(1, @gradFunc(x)).normalize()
			super at, grad, start, end, step

		getPoints: ->
			(@at(x) for x in _.range(@start, @end + @step, @step))