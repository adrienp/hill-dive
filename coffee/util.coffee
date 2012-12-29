define ['paper'], (paper) ->
    Point = paper.Point

    util = 
        intersect: (aFrom, aTo, bFrom, bTo) ->
            aVec = aTo.subtract(aFrom)
            bVec = bTo.subtract(bFrom)

            aT = (bVec.y * (bFrom.x - aFrom.x) + bVec.x * (aFrom.y - bFrom.y)) / (aVec.x * bVec.y - aVec.y * bVec.x)
            bT = (aFrom.y - bFrom.y + aT * aVec.y) / bVec.y

            if aT >= 0 and aT <= 1 and bT >= 0 and bT <= 1
                return aT

            return null

    window.util = util

    util