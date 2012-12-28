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

require ["canvas", "path", "flyer", "paper", "underscore"], (Canvas, Path, Flyer, paper, _) ->
	path = new Path Math.sin, Math.cos, Math.PI / 2, Math.PI * 20 + Math.PI / 2, 0.1
	flyer = new Flyer path
	canvas = new Canvas('game', path, [flyer])
	console.log path, canvas

	Point = paper.Point
	Path = paper.Path

	flyerPath = new Path()
	flyerPath.strokeColor = 'red'
	flyerPath.strokeWidth = 0.02

	canvas.view.setOnFrame (e) ->
		# path.at = (x) ->
		# 	new Point(x, Math.sin(e.time) * Math.sin(x))
		# path.grad = (x) ->
		# 	new Point(1, Math.sin(e.time) * Math.cos(x)).normalize()

		flyer.go(1 / 30)

		if flyer.pos.x > Math.PI * 20 + Math.PI / 2
			flyer.pos.x = Math.PI / 2
		# if flyer.pos.y > 10
		# 	flyer.pos.y = 10

		flyerFunc = flyer.getFunc().func
		flyerPathPoints = (new Point(x, flyerFunc(x)) for x in _.range(flyer.pos.x, Math.PI * 21, 0.1))
		# flyerPathPoints = (new Point(x, flyerFunc(x)) for x in _.range(Math.PI / 2, Math.PI * 21, 0.1))
		flyerPath.removeSegments()
		flyerPath.addSegments(flyerPathPoints)
		# console.log e.delta
		# if e.delta > 1 / 60
		canvas.draw()

	Point = paper.Point

	down = ->
		flyer.acc = new Point(0, 5)
		console.log flyer.acc

	up = ->
		flyer.acc = new Point(0, 1)
		console.log flyer.acc

	$(window).mousedown down

	$(window).mouseup up

	$(window).on 'touchstart', down
	$(window).on 'touchend', up

	window.path = path
