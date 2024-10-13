class "BoundingBox" {
    constructor = function(self, min, max)
        self.min = min
        self.max = max
    end,

    isPointInside = function(self, x, y, z)
        if x >= self.min.x and x <= self.max.x and y >= self.min.y and y <= self.max.y and z >= self.min.z and z <=
            self.max.z then
            return true
        end

        return false
    end,
}
