define ["paper"], (paper) ->
	Point = paper.Point

	class Flyer
		onPath: yes
		minSpeed: 0.5
		minXVel: 0.1

		constructor: (@path) ->
			@pos = @path.at(@path.start)
			@vel = new Point @minSpeed, 0
			@acc = new Point 0, 1

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
					console.log "JUMP"
					console.log "Pos:", @pos, "Path:", pathGrad, "Vel:", @vel
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
					dot = grad.dot(pathGrad)

					# if dot < 0.3
					# 	# Bounce
					# 	normal = new Point(pathGrad.y, -pathGrad.x)
					# 	reflection = @vel.subtract(@vel.project(normal).multiply(2)).multiply(0.5)
					# 	refLength = reflection.getLength()
					# 	@vel = reflection
					# 	if @vel.x < @minSpeed
					# 		@vel.y = Math.sqrt refLength * refLength - @minSpeed * @minSpeed
					# 	@pos = @path.at(intersection)
					# else
					console.log "HIT"
					console.log @vel, @path.grad(@pos.x)
					if grad.getAngle(pathGrad) < 90
						@vel = @vel.project @path.grad(@pos.x)
					else
						@vel = new Point(0, 0)
					console.log @vel
					@pos = @path.at @pos.x
					@onPath = yes

			@pos

		go: (dt) ->
			step = 1 / 60

			for i in [0..dt] by step
				@_go(step)

		getFunc: ->
			a = 1 / (2 * @vel.x * @vel.x)

			grad = @vel.y * (1 / @vel.x)

			b = grad - a * 2 * @pos.x


			c = @pos.y - a*@pos.x*@pos.x - b*@pos.x

			func: (x) -> a*x*x + b*x + c
			grad: (x) -> 2*a*x + b
