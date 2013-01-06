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

require ["jquery", "canvas", "channel", "randpath", "game"], ($, Canvas, Channel, RandPath, Game) ->

	class Main
		constructor: ->
			$('#name-form').on "submit", @nameSubmit
			$('#new-game-btn').on "click", @newGameBtn
			$('#game-list').on "click", ".join", @joinGame
			$('#refresh-games-btn').on "click", @refreshGames
			$('#new-game-form').on "submit", @newGameSubmit
			$('#start-btn').on "click", @startGame
			$('#done-btn').on "click", @doneBtn

			@canvas = new Canvas 'game'
			@$games = {}

		panel: (id) ->
			if id
				$('#panel > div').removeClass 'current'
				$("##{id}").addClass 'current'
			else
				$('#panel').hide()

		make$Game: (game) ->
			$("<li><button class='join' data-gid='#{game.gid}'>Join</button> #{game.name}</li>")

		refreshGames: =>
			$.get "/games",
				(games) =>
					$('#game-list').empty()
					@$games = {}

					for game in games
						$game = @make$Game game
						@$games[game.gid] = $game
						$('#game-list').append $game

		doneBtn: =>
			@panel "games"
			@refreshGames()

		newGameSubmit: (e) =>
			e.preventDefault()

			@panel "loading"

			name = $('#game-name-txt').val()
			length = parseFloat($('#length-num').val())
			height = parseFloat($('#height-num').val())
			freq = parseFloat($('#freq-num').val())

			path = RandPath.make length, height, freq, freq / 30

			data =
				yvals: path.yvals
				left: path.start
				freq: path.freq
				step: path.step

			$.post "/games",
				name: name
				host: @user.uid
				data: JSON.stringify(data),
				(game) =>
					if not game.success
						console.error game.msg
						@panel "games"
					else
						@game = new Game game.gid, @user, path, @channel, @canvas
						@gotoGameRoom game

		startGame: =>
			@panel "loading"

			$.post "/games/#{@game.gid}/start",
				uid: @user.uid,
				(resp) =>
					if not resp.success
						console.error resp.msg
						@panel "game-room"

		nameSubmit: (e) =>
			e.preventDefault()

			@panel "loading"

			name = $('#name-txt').val()

			@channel = new Channel name,
				(user) =>
					@user = user
					@panel "games"
					@refreshGames()

			@channel.on "join",
				(user) =>
					$('#members').append "<li>#{user.name}</li>"
					@game.addFlyer user

			@channel.on "gameCreate",
				(game) =>
					$game = @make$Game game
					@$games[game.gid] = $game
					$("#game-list").append $game

			@channel.on "gameStart",
				(game) =>
					$game = @$games[game.gid]
					$game.remove()
					delete @$games[game.gid]

		newGameBtn: =>
			@panel "new-game"

		gotoGameRoom: (game) ->
			@panel "game-room"
			$('#game-name').html game.name

			$('#members').empty()

			for user in game.users
				name = user.split(":")[0]
				$('#members').append "<li>#{name}</li>"

		joinGame: (e) =>
			@panel "loading"

			$target = $ e.target

			gid = $target.data('gid')

			$.post "/games/#{gid}/join",
				uid: @user.uid,
				(game) =>
					if not game.success
						@refreshGames()
						console.error game.msg
					else
						@game = new Game game.gid, @user, game.data, @channel, @canvas

						for user in game.users
							if user isnt @user.uid
								u =
									uid: user
									name: user.split(":")[0]
								@game.addFlyer u

						@gotoGameRoom game

	main = new Main()

    # length = 1000
    # freq = 3

    # canvas = new Canvas 'game'
    # path = RandPath.make length, 4, freq, 0.1
    # # path = new RandPath _.range(0, 10, 1), 0, 5, 0.1
    # flyer = new Flyer path, 'bird'

    # canvas.focus = flyer
    # canvas.path = path

    # flyer.setupControl(window)

    # count = 0
    # time = 0

    # canvas.view.setOnFrame (e) ->

    #     flyer.go(e.delta * 3)

    #     count += 1
    #     time += e.delta

    #     if time > 1
    #     	fps = Math.round(count * 10 / time) / 10
    #     	$('#fps').html fps + " fps"
    #     	count = 0
    #     	time = 0

    #     # if flyer.pos.x > path.end
    #     #     flyer.pos.x = path.start

    #     canvas.draw()
    #     flyer.draw()

    # window.path = path
