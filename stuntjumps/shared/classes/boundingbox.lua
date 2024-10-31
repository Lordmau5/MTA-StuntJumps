---@class BoundingBox: Class
BoundingBox = class()

function BoundingBox:init(min, max)
	self.min = min
	self.max = max
end

function BoundingBox.fromCorners(firstCorner, secondCorner)
	local minX = math.min(firstCorner.x, secondCorner.x)
	local maxX = math.max(firstCorner.x, secondCorner.x)

	local minY = math.min(firstCorner.y, secondCorner.y)
	local maxY = math.max(firstCorner.y, secondCorner.y)

	local minZ = math.min(firstCorner.z, secondCorner.z)
	local maxZ = math.max(firstCorner.z, secondCorner.z)

	return BoundingBox:new({
		x = minX,
		y = minY,
		z = minZ,
	}, {
		x = maxX,
		y = maxY,
		z = maxZ,
	})
end

function BoundingBox:isPointInside(x, y, z)
	if
		x >= self.min.x
		and x <= self.max.x
		and y >= self.min.y
		and y <= self.max.y
		and z >= self.min.z
		and z <= self.max.z
	then
		return true
	end

	return false
end
