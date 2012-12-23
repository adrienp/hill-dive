define ["paper", "jquery"], (paper, $) ->
	Path = paper.Path
	Point = paper.Point
	
	class Canvas
		constructor: (canvasId, @path, @flyers) ->
			paper.setup canvasId
			@view = paper.view

			@$window = $(window)

			@drawPath = new Path()
			@drawPath.strokeColor = 'black'

			for flyer in @flyers
				flyer.drawPath = new Path.Circle(flyer.pos, 3)
				flyer.drawPath.fillColor = 'red'

			@resize()
			@$window.resize @resize

			@view.draw()

			window.v = @view

		resize: =>
			windowSize = new Point(@$window.width() - 4, @$window.height() - 4)
			@view.setViewSize windowSize

			@zoom = windowSize.x / (@path.end - @path.start)
			@view.setCenter new Point((@path.end + @path.start) * @zoom / 2, @zoom + 10 - (windowSize.y / 2))
			@ceiling = @view.getBounds().y

			@drawPath.removeSegments()
			@drawPath.addSegments(p.multiply(new Point(@zoom, -@zoom)) for p in @path.getPoints())

			@draw()

		draw: ->
			for flyer in @flyers
				pos = flyer.pos.multiply(new Point(@zoom, -@zoom))
				if pos.y < @ceiling
					flyer.vel.y = -flyer.vel.y
				flyer.drawPath.setPosition pos

