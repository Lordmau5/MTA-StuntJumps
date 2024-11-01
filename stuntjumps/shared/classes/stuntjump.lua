---@class StuntJump: Class
StuntJump = class()

function StuntJump:init(id, startBox, endBox, camera, reward, ignoresHeight)
	self.id = id
	self.startBox = startBox.__class == "BoundingBox" and startBox or BoundingBox(startBox.min, startBox.max)
	self.endBox = endBox.__class == "BoundingBox" and endBox or BoundingBox(endBox.min, endBox.max)
	self.camera = camera
	self.reward = reward

	-- Default to not ignoring height
	self.ignoresHeight = ignoresHeight == true

	self.blip = nil
end

function StuntJump:setupBlip()
	if not localPlayer then
		return
	end

	self:destroyBlip()

	local centerX = (self.startBox.min.x + self.startBox.max.x) / 2
	local centerY = (self.startBox.min.y + self.startBox.max.y) / 2
	local centerZ = (self.startBox.min.z + self.startBox.max.z) / 2

	local ground = getGroundPosition(centerX, centerY, centerZ)

	self.blip = createBlip(centerX, centerY, centerZ, 0, 1, 0, 255, 255, 255, 0, 65535)
end

function StuntJump:destroyBlip()
	if isElement(self.blip) then
		destroyElement(self.blip)
	end
end

function StuntJump:isInStartBox(x, y, z)
	return self.startBox:isPointInside(x, y, z)
end

function StuntJump:isInEndBox(x, y, z)
	return self.endBox:isPointInside(x, y, z)
end

function StuntJump:doesIgnoreHeight()
	return self.ignoresHeight
end
