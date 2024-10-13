class "StuntJump" {
    constructor = function(self, id, startBox, endBox, camera, reward)
        self.id = id
        self.startBox = BoundingBox(startBox.min, startBox.max)
        self.endBox = BoundingBox(endBox.min, endBox.max)
        self.camera = camera
        self.reward = reward
        self.done = false

        self:setupBlip()
    end,

    setupBlip = function(self)
        local centerX = (self.startBox.min.x + self.startBox.max.x) / 2
        local centerY = (self.startBox.min.y + self.startBox.max.y) / 2
        local centerZ = (self.startBox.min.z + self.startBox.max.z) / 2

        self.blip = createBlip(centerX, centerY, centerZ, 0, 1, 0, 255, 255, 255, 0, 65535)
    end,

    isInStartBox = function(self, x, y, z)
        return self.startBox:isPointInside(x, y, z)
    end,

    isInEndBox = function(self, x, y, z)
        return self.endBox:isPointInside(x, y, z)
    end,

    isJumpDone = function(self)
        return self.done
    end,

    setJumpDone = function(self, done)
        self.done = (done ~= nil) and done or true

        destroyElement(self.blip)
    end,
}
