class "StuntJump" {
    constructor = function(self, id, startBox, endBox, camera, reward)
        self.id = id
        self.startBox = startBox.__class == "BoundingBox" and startBox or BoundingBox(startBox.min, startBox.max)
        self.endBox = endBox.__class == "BoundingBox" and endBox or BoundingBox(endBox.min, endBox.max)
        self.camera = camera
        self.reward = reward
        self.done = false
    end,

    setupBlip = function(self)
        self:destroyBlip()

        local centerX = (self.startBox.min.x + self.startBox.max.x) / 2
        local centerY = (self.startBox.min.y + self.startBox.max.y) / 2
        local centerZ = (self.startBox.min.z + self.startBox.max.z) / 2

        self.blip = createBlip(centerX, centerY, centerZ, 0, 1, 0, 255, 255, 255, 0, 65535)
    end,

    destroyBlip = function(self)
        if isElement(self.blip) then
            destroyElement(self.blip)
        end
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
        self.done = done == nil and true or done

        self:destroyBlip()

        -- If we reset to not done, recreate the blip
        if not self.done then
            self:setupBlip()
        end
    end,
}
