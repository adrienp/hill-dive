require.config
	# baseUrl: "js/"
	paths:
		jquery: "lib/jquery-1.8.3"
		goog: "/_ah/channel/jsapi?"
		backbone: "lib/backbone"
		underscore: "lib/underscore"
		paper: "lib/paper"

	shim:
		goog:
			exports: "goog"
		paper:
			exports: "paper"
		underscore:
			exports: "_"

require ["canvas", "path", "flyer", "paper", "underscore", "randpath"], (Canvas, Path, Flyer, paper, _, RandPath) ->
	# path = new Path Math.sin, Math.cos, Math.PI / 2, Math.PI * 400 + Math.PI / 2, 0.1
	left = 0
	right = 1000
	freq = 3
	path = new RandPath left, right, 2, -2, freq, 0.1
	flyer = new Flyer path
	canvas = new Canvas('game', path, [flyer])
	console.log path, canvas

	# for x in [left...right] by freq
	# 	c = new paper.Path.Circle(x, 0, 0.3)
	# 	c.fillColor = 'green'

	Point = paper.Point
	Path = paper.Path

	flyerPath = new Path()
	flyerPath.strokeColor = 'green'
	flyerPath.strokeWidth = 0.02
	flyerPath.dashArray = [0.2, 0.1]

	canvas.view.setOnFrame (e) ->
		# path.at = (x) ->
		# 	new Point(x, Math.sin(e.time) * Math.sin(x))
		# path.grad = (x) ->
		# 	new Point(1, Math.sin(e.time) * Math.cos(x)).normalize()

		flyer.go(1 / 30)

		if flyer.pos.x > path.end
			flyer.pos.x = path.start
		# if flyer.pos.y > 10
		# 	flyer.pos.y = 10

		flyerFunc = flyer.getFunc().func
		b = paper.view.getBounds()
		flyerPathPoints = (new Point(x, flyerFunc(x)) for x in _.range(flyer.pos.x, b.x + b.width, 0.1))
		# flyerPathPoints = (new Point(x, flyerFunc(x)) for x in _.range(Math.PI / 2, Math.PI * 21, 0.1))
		flyerPath.removeSegments()
		flyerPath.addSegments(flyerPathPoints)
		# console.log e.delta * 60
		# if e.delta > 1 / 60
		canvas.draw()

	Point = paper.Point

	down = ->
		flyer.acc = new Point(0, 5)
		# console.log flyer.acc

	up = ->
		flyer.acc = new Point(0, 1)
		# console.log flyer.acc

	$(window).mousedown down

	$(window).mouseup up

	$(window).on 'touchstart', down
	$(window).on 'touchend', up

	window.path = path
