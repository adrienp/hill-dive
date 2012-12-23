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

require ["canvas", "path", "flyer", "paper"], (Canvas, Path, Flyer, paper) ->
	path = new Path Math.sin, Math.cos, Math.PI / 2, Math.PI * 20 + Math.PI / 2, 0.1
	flyer = new Flyer path
	canvas = new Canvas('game', path, [flyer])
	console.log path, canvas

	canvas.view.setOnFrame ->
		flyer.go(1/30)
		if flyer.pos.x > Math.PI * 20 + Math.PI / 2
			flyer.pos.x = Math.PI / 2
		# if flyer.pos.y > 10
		# 	flyer.pos.y = 10
		canvas.draw()

	Point = paper.Point

	$(window).mousedown ->
		flyer.acc = new Point(0, -5)
		console.log flyer.acc

	$(window).mouseup ->
		flyer.acc = new Point(0, -1)
		console.log flyer.acc
