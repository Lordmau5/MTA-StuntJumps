-- BOUNDING BOX MOVEMENT --
-- movement keys of the bounding box: up, down, left, right arrow to move it depending on where you look
-- switch to scale mode (holding ctrl?), which will scale it in the direction you're looking
-- + and - to move it up or down (or scale it up or down)

---@class BoundingBoxEditorClass: Class
BoundingBoxEditorClass = class()

function BoundingBoxEditorClass:init()
	addEventHandler("onClientKey", root, function(button, press)
		self:onKeyPressed(button, press)
	end)
end

function BoundingBoxEditorClass:onKeyPressed(button, press)
	if not press or not Editor:isEditModeActive() then
		return
	end

	local editBoundingBox, boxType = Editor:getActiveEditBoundingBox()
	if not editBoundingBox then
		return
	end

	-- Check the player's camera position and look at direction
	local cameraX, cameraY, cameraZ, lookAtX, lookAtY, lookAtZ = getCameraMatrix()
	local cameraFacingDirection = "north" -- default direction

	-- Calculate the camera's forward vector
	local forwardX = lookAtX - cameraX
	local forwardY = lookAtY - cameraY

	-- Normalize the forward vector for accurate direction calculation
	local magnitude = math.sqrt(forwardX ^ 2 + forwardY ^ 2)
	if magnitude > 0 then
		forwardX = forwardX / magnitude
		forwardY = forwardY / magnitude
	end

	-- Determine the direction based on the camera's forward vector
	if forwardX < 0 and math.abs(forwardX) > math.abs(forwardY) then
		cameraFacingDirection = "west"
	elseif forwardX > 0 and math.abs(forwardX) > math.abs(forwardY) then
		cameraFacingDirection = "east"
	elseif forwardY < 0 and math.abs(forwardY) > math.abs(forwardX) then
		cameraFacingDirection = "south"
	elseif forwardY > 0 and math.abs(forwardY) > math.abs(forwardX) then
		cameraFacingDirection = "north"
	end

	-- Direction mappings for arrow keys
	local directionMappings = {
		arrow_u = cameraFacingDirection,
		arrow_d = {
			north = "south",
			south = "north",
			east = "west",
			west = "east",
		},
		arrow_l = {
			north = "west",
			south = "east",
			east = "north",
			west = "south",
		},
		arrow_r = {
			north = "east",
			south = "west",
			east = "south",
			west = "north",
		},
	}

	if button == "pgup" then
		self:moveOrScaleBoundingBox(editBoundingBox, boxType, "up")
	elseif button == "pgdn" then
		self:moveOrScaleBoundingBox(editBoundingBox, boxType, "down")
	elseif directionMappings[button] then
		local direction = directionMappings[button]
		if type(direction) == "table" then
			self:moveOrScaleBoundingBox(editBoundingBox, boxType, direction[cameraFacingDirection])
		else
			self:moveOrScaleBoundingBox(editBoundingBox, boxType, direction)
		end
	end
end

function BoundingBoxEditorClass:moveOrScaleBoundingBox(box, boxType, direction)
	local speed = 1

	local alt = (getKeyState("lalt") or getKeyState("ralt")) and 0.5 or 1
	speed = speed * alt

	local shift = (getKeyState("lshift") or getKeyState("rshift")) and 4 or 1
	speed = speed * shift

	local isScaling = getKeyState("lctrl") or getKeyState("rctrl")

	-- Determine the amount to move based on speed
	local moveAmount = isScaling and 0 or speed
	local scaleFactor = isScaling and speed or 0

	-- Move all corners of the box when not scaling
	if not isScaling then
		if direction == "up" then
			box.min.z = box.min.z + moveAmount
			box.max.z = box.max.z + moveAmount
		elseif direction == "down" then
			box.min.z = box.min.z - moveAmount
			box.max.z = box.max.z - moveAmount
		elseif direction == "north" then
			box.min.y = box.min.y + moveAmount
			box.max.y = box.max.y + moveAmount
		elseif direction == "south" then
			box.min.y = box.min.y - moveAmount
			box.max.y = box.max.y - moveAmount
		elseif direction == "east" then
			box.min.x = box.min.x + moveAmount
			box.max.x = box.max.x + moveAmount
		elseif direction == "west" then
			box.min.x = box.min.x - moveAmount
			box.max.x = box.max.x - moveAmount
		end
	else
		-- If scaling, adjust only the relevant corners
		if direction == "up" then
			box.max.z = box.max.z + scaleFactor
		elseif direction == "down" then
			box.max.z = box.max.z - scaleFactor
		elseif direction == "north" then
			box.max.y = box.max.y + scaleFactor
		elseif direction == "south" then
			box.max.y = box.max.y - scaleFactor
		elseif direction == "east" then
			box.max.x = box.max.x + scaleFactor
		elseif direction == "west" then
			box.max.x = box.max.x - scaleFactor
		end
	end

	-- Always call this to update the bounding box in the UI
	Editor:updateEditBoundingBox(box, boxType)
end

BoundingBoxEditor = BoundingBoxEditorClass:new() --[[@as BoundingBoxEditorClass]]
