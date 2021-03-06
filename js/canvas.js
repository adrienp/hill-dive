// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["paper", "jquery"], function(paper, $) {
    var Canvas, Gradient, GradientColor, Group, Layer, Matrix, Path, Point, Raster, Size;
    Path = paper.Path, Point = paper.Point, Matrix = paper.Matrix, Raster = paper.Raster, Size = paper.Size, Group = paper.Group, Layer = paper.Layer, Gradient = paper.Gradient, GradientColor = paper.GradientColor;
    return Canvas = (function() {

      function Canvas(canvasId) {
        this.resize = __bind(this.resize, this);
        paper.setup(canvasId);
        this.view = paper.view;
        this.$window = $(window);
        this.resize();
        this.$window.resize(this.resize);
        this.view.draw();
        window.v = this.view;
      }

      Canvas.prototype.resize = function() {
        var windowSize;
        windowSize = new Point(this.$window.width() - 4, this.$window.height() - 4);
        this.view.setViewSize(windowSize);
        return this.draw();
      };

      Canvas.prototype.setFrame = function(x, xPerc, bottom, top) {
        var centerX, height, width;
        height = this.view.getViewSize().getHeight();
        this.view.setZoom(height / (bottom - top));
        width = this.view.getBounds().width;
        xPerc -= 0.5;
        centerX = x - xPerc * width;
        return this.view.setCenter(new Point(centerX, (top + bottom) / 2));
      };

      Canvas.prototype.showAll = function() {
        var width;
        if (this.path) {
          width = this.view.getViewSize().getWidth();
          this.view.setZoom(width / (this.path.end - this.path.start));
          return this.view.setCenter(new Point((this.path.end + this.path.start) / 2, (this.path.range.bottom + this.path.range.top) / 2));
        }
      };

      Canvas.prototype.draw = function() {
        var bottom, buffer, focusPos, top;
        if (this.focus) {
          focusPos = this.focus.getPosition();
          top = Math.min(focusPos.y, this.path.range.top);
          bottom = this.path.range.bottom;
          buffer = (bottom - top) * 0.3;
          top -= buffer;
          bottom += buffer;
          return this.setFrame(focusPos.x, 0.15, bottom, top);
        } else {
          return this.showAll();
        }
      };

      Canvas.prototype.clear = function() {
        return paper.project.activeLayer.removeChildren();
      };

      return Canvas;

    })();
  });

}).call(this);
