define ["paper"], (paper) ->
	Point = paper.Point

	class Flyer
		onPath: yes
		minXVel: 1

		constructor: (@path) ->
			@pos = @path.at(@path.start)
			@vel = new Point @minXVel, 0
			@acc = new Point 0, -1

		go: (dt) ->
			@vel = @vel.add @acc.multiply(dt)

			@vel.x = Math.max @vel.x, @minXVel
			
			if @onPath
				pathGrad = @path.grad(@pos.x)

				if pathGrad.getDirectedAngle(@vel) > 0
					# Jumping off path
					@onPath = no
				else
					# Staying on path
					@vel = pathGrad.normalize @vel.getLength()
					@pos = @path.at(@pos.add(@vel.multiply(dt)).x)
			if not @onPath
				@pos = @pos.add @vel.multiply(dt)

				if @pos.y < @path.at(@pos.x).y
					# If path collision
					@vel = @vel.project @path.grad(@pos.x)
					@pos = @path.at @pos.x
					@onPath = yes

			@pos

