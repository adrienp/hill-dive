define ['path', 'underscore', 'paper'], (Path, _, paper) ->

    class RandPath extends Path
        constructor: (@yvals, left, freq, step) ->
            @freq = freq
            
            right = left + (@yvals.length - 1) * freq

            cubic = (x) =>
                i = Math.floor((x - left) / freq)
                x -= i * freq
                x /= freq

                p0 = @yval(i - 1)
                p1 = @yval(i)
                p2 = @yval(i + 1)
                p3 = @yval(i + 2)

                # m1 = (p2 - p0) / (2 * freq)
                # m2 = (p3 - p1) / (2 * freq)

                m1 = (p2 - p0) / 2
                m2 = (p3 - p1) / 2

                a: 2*p1 - 2*p2 + m1 + m2
                b: -3*p1 + 3*p2 - 2*m1 - m2
                c: m1
                d: p1
                x: x

            func = (x) ->
                {a,b,c,d,x} = cubic(x)

                (a * x*x*x) + (b * x*x) + (c * x) + d

            grad = (x) ->
                {a,b,c,d,x} = cubic(x)

                ((3 * a * x*x) + (2 * b * x) + c) / freq

            super func, grad, left, right, step

        yval: (i) ->
            i = Math.max(Math.min(i, @yvals.length - 1), 0)
            @yvals[i]

        @make = (length, amp, freq, step) ->
            yvals = (Math.random() * amp for i in _.range(0, length + freq, freq))

            new RandPath yvals, 0, freq, step
