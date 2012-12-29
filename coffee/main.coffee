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
    left = 0
    right = 1000
    freq = 3

    canvas = new Canvas 'game'
    path = RandPath.make left, right, 2, -2, freq, 0.1
    flyer = new Flyer path, 'bird'

    canvas.focus = flyer
    canvas.path = path

    flyer.setupControl(window)

    canvas.view.setOnFrame (e) ->

        flyer.go(e.delta * 3)

        # if flyer.pos.x > path.end
        #     flyer.pos.x = path.start

        canvas.draw()
        flyer.draw()

    window.path = path
