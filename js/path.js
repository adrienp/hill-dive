// Generated by CoffeeScript 1.4.0
(function() {

  define(["paper", "underscore", "util"], function(paper, _, util) {
    var Path, Point;
    Point = paper.Point;
    return Path = (function() {

      function Path(func, gradFunc, start, end, step) {
        this.func = func;
        this.gradFunc = gradFunc;
        this.start = start;
        this.end = end;
        this.step = step;
        this.at = function(x) {
          return new Point(x, this.func(x));
        };
        this.grad = function(x) {
          return new Point(1, this.gradFunc(x)).normalize();
        };
        this.range = this._range(this.start, this.end);
      }

      Path.prototype.getPoints = function() {
        var x, _i, _len, _ref, _results;
        _ref = _.range(this.start, this.end + this.step, this.step);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          _results.push(this.at(x));
        }
        return _results;
      };

      Path.prototype._range = function(left, right) {
        var leftY, ret, x, y, _i, _ref;
        leftY = this.func(left);
        ret = {
          top: leftY,
          bottom: leftY
        };
        for (x = _i = left, _ref = this.step; left <= right ? _i < right : _i > right; x = _i += _ref) {
          y = this.func(x);
          if (y < ret.top) {
            ret.top = y;
          }
          if (y > ret.bottom) {
            ret.bottom = y;
          }
        }
        return ret;
      };

      Path.prototype.intersect = function(func, grad, leftBound, rightBound, error) {
        var intFunc, intGrad, leftDif, rightDif, x,
          _this = this;
        if (error == null) {
          error = null;
        }
        intFunc = function(x) {
          return func(x) - _this.func(x);
        };
        intGrad = function(x) {
          return grad(x) - _this.gradFunc(x);
        };
        leftDif = intFunc(leftBound);
        rightDif = intFunc(rightBound);
        if ((leftDif > 0 && rightDif > 0) || (leftDif < 0 && rightDif < 0)) {
          return null;
        }
        x = (rightBound + leftBound) / 2;
        error = error || this.step / 2;
        while (Math.abs(intFunc(x)) > error) {
          x = x - intFunc(x) / intGrad(x);
        }
        return x;
      };

      return Path;

    })();
  });

}).call(this);
