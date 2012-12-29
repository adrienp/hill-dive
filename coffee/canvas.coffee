define ["paper", "jquery"], (paper, $) ->
	{Path, Point, Matrix, Raster, Size, Group, Layer, Gradient, GradientColor} = paper
	
	class Canvas
		constructor: (canvasId, @path, @flyers) ->
			paper.setup canvasId
			@view = paper.view

			@$window = $(window)

			@sky = new Path.Rectangle(new Point(@path.start - 5, 2), new Point(@path.end + 5, -10))
			grad = new Gradient(["#AADAFA", "#027ED1"])
			grad = new GradientColor(grad, new Point(0, -10), new Point(0, 2))
			@sky.fillColor = grad

			grad = new Gradient(["#98FA37", "#2A8000"])
			grad = new GradientColor(grad, new Point(0, -2), new Point(0, 5))

			@drawPath = new Path()
			@drawPath._hill = true
			@drawPath.strokeColor = 'black'
			@drawPath.strokeWidth = 0.05
			@drawPath.fillColor = grad
			@drawPath.addSegments(@path.getPoints())

			# dot = new Path.Circle(new Point(3, 0), 2)
			# dot.fillColor = 'red'

			
			# g.opacity = 0.99

			# @gradPath = new Path()
			# @gradPath.strokeColor = 'blue'
			# @gradPath.strokeWidth = 0.05
			# @gradPath.addSegments(@path.getGradPoints())

			# l = new Layer()

			for flyer in @flyers
				loadBird = ->
					flyer.raster = new Raster('bird')
					flyer.raster.setSize new Size(128, 128)
					flyer.raster.scale 1 / 128
					flyer.raster.rot = 0
					window.raster = flyer.raster

				if $('#bird')[0].complete
					loadBird()
				else
					$('#bird').load loadBird
				# flyer.raster.setSize(new Size(100, 100))
				# flyer.raster.setPosition @view.getCenter()
				# flyer.drawPath = new Path.Circle(flyer.pos, 0.1)
				# flyer.drawPath.fillColor = 'red'

			# l = new Layer()
			# clipPath = @drawPath.clone()
			# clipPath._hill = true

			# g = new Group([clipPath, dot])
			# g.setClipped(true)
			# window.clipGroup = g

			@focus = @flyers[0]

			@resize()
			@$window.resize @resize

			@view.draw()

			window.v = @view

		resize: =>
			windowSize = new Point(@$window.width() - 4, @$window.height() - 4)
			@view.setViewSize windowSize

			# @zoom = windowSize.x / (@path.end - @path.start)
			# @view.setCenter new Point((@path.end + @path.start) * @zoom / 2, @zoom + 10 - (windowSize.y / 2))
			# @ceiling = @view.getBounds().y

			# @drawPath.removeSegments()
			# @drawPath.addSegments(@transformPoints(@path.getPoints()))

			@draw()

		setFrame: (x, xPerc, bottom, top) ->
			# bounds = @view.getBounds()
			height = @view.getViewSize().getHeight()
			@view.setZoom(height / (bottom - top))

			width = @view.getBounds().width
			xPerc -= 0.5
			centerX = x - xPerc * width

			@view.setCenter(new Point(centerX, (top + bottom) / 2))

		draw: ->
			for flyer in @flyers
				# pos = flyer.pos
				# if pos.y < @ceiling
				# 	flyer.vel.y = -flyer.vel.y
				# flyer.drawPath.setPosition flyer.pos
				if flyer.raster
					pos = flyer.pos.add(flyer.vel.rotate(-90).normalize(0.5))
					flyer.raster.setPosition pos
					rot = flyer.vel.angle - flyer.raster.rot
					flyer.raster?.rotate rot
					flyer.raster.rot += rot

			top = Math.min(@focus.pos.y, @path.range.top)
			bottom = @path.range.bottom

			buffer = (bottom - top) * 0.3

			top -= buffer
			bottom += buffer

			@setFrame(@focus.pos.x, 0.15, bottom, top)
			# @setFrame(Math.PI / 10, 4, -4)

