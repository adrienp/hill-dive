// Generated by CoffeeScript 1.4.0
(function() {

  define(['paper'], function(paper) {
    var Point, util;
    Point = paper.Point;
    util = {
      intersect: function(aFrom, aTo, bFrom, bTo) {
        var aT, aVec, bT, bVec;
        aVec = aTo.subtract(aFrom);
        bVec = bTo.subtract(bFrom);
        aT = (bVec.y * (bFrom.x - aFrom.x) + bVec.x * (aFrom.y - bFrom.y)) / (aVec.x * bVec.y - aVec.y * bVec.x);
        bT = (aFrom.y - bFrom.y + aT * aVec.y) / bVec.y;
        if (aT >= 0 && aT <= 1 && bT >= 0 && bT <= 1) {
          return aT;
        }
        return null;
      }
    };
    window.util = util;
    return util;
  });

}).call(this);
