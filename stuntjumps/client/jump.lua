---@class JumpClass: Class
JumpClass = class()

function JumpClass:init()
	self.currentTime = 0
	self.timerCheckDelay = 0

	self.stuntJumpState = "start"
	self.currentJump = nil
	self.hitEndTrigger = false
	self.groundGracePeriod = 0

	self.vehicle = nil

	setTimer(function()
		self:gameTick()
	end, 100, 0)

	addEventHandler("onClientRender", root, function()
		self:updateCameraDuringStuntJump()
	end)
end

function JumpClass:getCurrentStuntJump()
	return self.currentJump
end

function JumpClass:getHitEndTrigger(jump)
	jump = jump ~= nil and jump or self.currentJump

	if jump == nil or jump ~= self.currentJump then
		return false
	end

	return self.hitEndTrigger
end

-- Wheel on ground calculation
function JumpClass:isAnyWheelOnGround()
	for i = 0, 3 do
		if isVehicleWheelOnGround(self.vehicle, i) then
			self.groundGracePeriod = self.currentTime + 500
			return true
		end
	end

	-- Allow a grace period after the vehicle gets airborne to still count as "on ground"
	if self.currentTime < self.groundGracePeriod then
		return true
	end

	return false
end

-- If the vehicle is driving the minimum required speed to trigger a Starting stunt jump
-- https://github.com/gta-reversed/gta-reversed-modern/blob/master/source/game_sa/StuntJumpManager.cpp#L111
function JumpClass:isVehicleDrivingJumpSpeed()
	if not self.vehicle or not getElementVelocity(self.vehicle) then
		return false
	end

	local veloX, veloY, veloZ = getElementVelocity(self.vehicle)
	return (math.sqrt(veloX ^ 2 + veloY ^ 2 + veloZ ^ 2) * 50) >= 20
end

function JumpClass:isVehicleMovingUpwards(jump)
	if not self.vehicle or not getElementVelocity(self.vehicle) or not jump then
		return false
	end

	local _, _, veloZ = getElementVelocity(self.vehicle)

	-- Check if Z velocity is upward at least a bit
	-- This prevents jumps from triggering when jumping *down*
	return jump:doesIgnoreHeight() or veloZ >= 0.1
end

-- If all the conditions are met to trigger the start of a stunt jump
-- https://github.com/gta-reversed/gta-reversed-modern/blob/master/source/game_sa/StuntJumpManager.cpp#L101-L111
function JumpClass:isStuntJumpStartSatisfied()
	if not self.vehicle then
		return false
	end

	if getVehicleOccupant(self.vehicle, 0) ~= localPlayer then
		return false
	end

	local vehicleType = getVehicleType(self.vehicle)
	if vehicleType == "Plane" or vehicleType == "Helicopter" or vehicleType == "Boat" then
		return false
	end

	if not self:isAnyWheelOnGround() then
		return false
	end

	if not self:isVehicleDrivingJumpSpeed() then
		return false
	end

	return true
end

-- Gets the stunt jump for the current position
function JumpClass:getStuntJumpForPosition()
	if not self.vehicle then
		return nil
	end

	local posX, posY, posZ = getElementPosition(self.vehicle)
	return StuntJumps:getJumpForStartBox(posX, posY, posZ)
end

function JumpClass:isFailureStateMet()
	if not self.currentJump then
		return true
	end

	if not self.vehicle then
		return true
	end

	if self:isAnyWheelOnGround() and self.currentTime > self.timerCheckDelay then
		return true
	end

	if isElementInWater(self.vehicle) then
		return true
	end

	return false
end

function JumpClass:gameTick()
	self.currentTime = getTickCount()
	self.vehicle = getPedOccupiedVehicle(localPlayer)

	if self.stuntJumpState == "start" then
		if not self:isStuntJumpStartSatisfied() then
			return
		end

		local jump = self:getStuntJumpForPosition()
		if not jump then
			return
		end

		if not self:isVehicleMovingUpwards(jump) then
			return false
		end

		setGameSpeed(0.3)

		self.stuntJumpState = "air"
		self.currentJump = jump
		self.timerCheckDelay = self.currentTime + 2000
		self.hitEndTrigger = false

		outputChatBox("Starting stunt jump!")
	elseif self.stuntJumpState == "air" then
		if not self.currentJump then
			stuntJumpState = "start"
			return
		end

		-- Player not in vehicle
		if not self.vehicle then
			self.stuntJumpState = "land"
			self.timerCheckDelay = self.currentTime + 1000
			return
		end

		local posX, posY, posZ = getElementPosition(self.vehicle)
		if self.currentJump:isInEndBox(posX, posY, posZ) and not self.hitEndTrigger then
			self.hitEndTrigger = true
			if not Completions:isJumpCompleted(self.currentJump) then
				playSFX("genrl", 52, 18, false)
			end
		end

		local failed = self:isFailureStateMet()
		if failed then
			self.stuntJumpState = "land"
			self.timerCheckDelay = self.currentTime + 1000
		end
	elseif self.stuntJumpState == "land" then
		if self.currentTime < self.timerCheckDelay then
			return
		end

		setGameSpeed(1)
		setCameraTarget(localPlayer)

		local isJumpCompleted = Completions:isJumpCompleted(self.currentJump)

		if self.hitEndTrigger and not isJumpCompleted then
			Completions:setJumpCompleted(self.currentJump)
			outputChatBox("Completed stunt jump!", 0, 230, 0)
		else
			if isJumpCompleted then
				outputChatBox("You've already completed this jump before.", 230, 0, 0)
			elseif not self.hitEndTrigger then
				outputChatBox("You've not hit the end trigger.", 230, 0, 0)
			end
		end

		self.stuntJumpState = "start"
		self.currentJump = nil
		self.hitEndTrigger = false
	end
end

function JumpClass:updateCameraDuringStuntJump()
	if self.currentJump then
		local cam = self.currentJump.camera
		if cam and cam.x then
			local posX, posY, posZ = getElementPosition(localPlayer)
			local pos = Vector3(posX, posY, posZ)

			if cam.lookAtX then
				pos = Vector3(cam.lookAtX, cam.lookAtY, cam.lookAtZ)
			end

			setCameraMatrix(cam.x, cam.y, cam.z, pos.x, pos.y, pos.z)
		end
	end
end

Jump = JumpClass() --[[@as JumpClass]]
