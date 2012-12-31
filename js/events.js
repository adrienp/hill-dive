// Generated by CoffeeScript 1.4.0
(function() {

  define([], function() {
    var Events;
    return Events = (function() {

      function Events() {
        this.events = {};
      }

      Events.prototype.trigger = function(eventType, msg) {
        var fn, _i, _len, _ref, _results;
        if (msg == null) {
          msg = this;
        }
        if (eventType in this.events) {
          _ref = this.events[eventType];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            fn = _ref[_i];
            _results.push(typeof fn === "function" ? fn(msg) : void 0);
          }
          return _results;
        }
      };

      Events.prototype.on = function(eventType, fn) {
        if (!(eventType in this.events)) {
          this.events[eventType] = [];
        }
        return this.events[eventType].push(fn);
      };

      Events.prototype.off = function(eventType, fn) {
        var i, _ref;
        if (fn == null) {
          fn = null;
        }
        if (fn) {
          i = (_ref = this.events[eventType]) != null ? _ref.indexOf(fn) : void 0;
          if ((i != null) >= 0) {
            return this.events[eventType].splice(i, 1);
          }
        } else {
          return delete this.events[eventType];
        }
      };

      return Events;

    })();
  });

}).call(this);
