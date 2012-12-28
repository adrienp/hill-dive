define ["paper", "jquery"], (paper, $) ->
	Path = paper.Path
	Point = paper.Point
	Matrix = paper.Matrix
	
	class Canvas
		constructor: (canvasId, @path, @flyers) ->
			paper.setup canvasId
			@view = paper.view

			@$window = $(window)

			@drawPath = new Path()
			@drawPath.strokeColor = 'black'
			@drawPath.strokeWidth = 0.05
			@drawPath.addSegments(@path.getPoints())

			for flyer in @flyers
				flyer.drawPath = new Path.Circle(flyer.pos, 0.1)
				flyer.drawPath.fillColor = 'red'

			@focus = @flyers[0]

			@resize()
			@$window.resize @resize

			@view.draw()

			window.v = @view

		resize: =>
			windowSize = new Point(@$window.width() - 2, @$window.height() - 2)
			@view.setViewSize windowSize

			# @zoom = windowSize.x / (@path.end - @path.start)
			# @view.setCenter new Point((@path.end + @path.start) * @zoom / 2, @zoom + 10 - (windowSize.y / 2))
			# @ceiling = @view.getBounds().y

			# @drawPath.removeSegments()
			# @drawPath.addSegments(@transformPoints(@path.getPoints()))

			@draw()

		setFrame: (centerX, bottom, top) ->
			# bounds = @view.getBounds()
			height = @view.getViewSize().getHeight()

			@view.setCenter(new Point(centerX, (top + bottom) / 2))
			@view.setZoom(height / (bottom - top))

		draw: ->
			for flyer in @flyers
				# pos = flyer.pos
				# if pos.y < @ceiling
				# 	flyer.vel.y = -flyer.vel.y
				flyer.drawPath.setPosition flyer.pos

			top = Math.min(@focus.pos.y, @path.range.top)
			bottom = @path.range.bottom

			buffer = (bottom - top) * 0.3

			top -= buffer
			bottom += buffer

			@setFrame(@focus.pos.x, bottom, top)
			# @setFrame(Math.PI / 10, 4, -4)

