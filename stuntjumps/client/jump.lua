class "c_Jump" {
    constructor = function(self)
        self.currentTime = 0
        self.timerCheckDelay = 0

        self.stuntJumpState = "start"
        self.currentStuntJump = nil
        self.groundGracePeriod = 0

        self.vehicle = nil

        setTimer(function()
            self:gameTick()
        end, 100, 0)

        addEventHandler("onClientRender", root, function()
            self:updateCameraDuringStuntJump()
        end)
    end,

    getCurrentStuntJump = function(self)
        return self.currentStuntJump
    end,

    -- Wheel on ground calculation
    isAnyWheelOnGround = function(self)
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
    end,

    -- If the vehicle is driving the minimum required speed to trigger a Starting stunt jump
    -- https://github.com/gta-reversed/gta-reversed-modern/blob/master/source/game_sa/StuntJumpManager.cpp#L111
    isVehicleDrivingJumpSpeed = function(self)
        if not self.vehicle then
            return false
        end

        local vx, vy, vz = getElementVelocity(self.vehicle)
        return (math.sqrt(vx ^ 2 + vy ^ 2 + vz ^ 2) * 50) >= 20
    end,

    isVehicleMovingUpwards = function(self)
        local vx, vy, vz = getElementVelocity(self.vehicle)

        -- Check if Z velocity is upward at least a bit
        -- This prevents jumps from triggering when jumping *down*
        return vz >= 0.1
    end,

    -- If all the conditions are met to trigger the start of a stunt jump
    -- https://github.com/gta-reversed/gta-reversed-modern/blob/master/source/game_sa/StuntJumpManager.cpp#L101-L111
    isStuntJumpStartSatisfied = function(self)
        if not self.vehicle then
            return false
        end

        if getVehicleOccupant(self.vehicle) ~= localPlayer then
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

        if not self:isVehicleMovingUpwards() then
            return false
        end

        return true
    end,

    getVehiclePosition = function(self)
        if not self.vehicle then
            return nil
        end

        return getElementPosition(self.vehicle)
    end,

    -- Gets the stunt jump for the current position
    getStuntJumpForPosition = function(self)
        local vehX, vehY, vehZ = self:getVehiclePosition()
        -- Player not in vehicle
        if not vehX then
            return nil
        end

        return StuntJumps:getJumpForStartBox(vehX, vehY, vehZ)
    end,

    isFailureStateMet = function(self)
        if not self.currentStuntJump then
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
    end,

    gameTick = function(self)
        self.currentTime = getTickCount()
        self.vehicle = getPedOccupiedVehicle(localPlayer)

        if self.stuntJumpState == "start" then
            if not self:isStuntJumpStartSatisfied() then
                return
            end

            local tempStuntJump = self:getStuntJumpForPosition()
            if not tempStuntJump then
                return
            end

            setGameSpeed(0.3)

            self.stuntJumpState = "air"
            self.currentStuntJump = tempStuntJump
            self.timerCheckDelay = self.currentTime + 2000
            self.currentStuntJump.hitEndTrigger = false

            outputChatBox("Starting stunt jump!")
        elseif self.stuntJumpState == "air" then
            if not self.currentStuntJump then
                stuntJumpState = "start"
                return
            end

            local vehX, vehY, vehZ = self:getVehiclePosition()
            -- Player not in vehicle
            if not vehX then
                self.stuntJumpState = "land"
                self.timerCheckDelay = self.currentTime + 1000
                return
            end

            if self.currentStuntJump:isInEndBox(vehX, vehY, vehZ) and not self.currentStuntJump.hitEndTrigger then
                self.currentStuntJump.hitEndTrigger = true
                if not self.currentStuntJump.done then
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

            if self.currentStuntJump.hitEndTrigger and not self.currentStuntJump.done then
                self.currentStuntJump:setJumpDone()
                outputChatBox("Completed stunt jump!", 0, 230, 0)
            else
                if self.currentStuntJump.done then
                    outputChatBox("You've already completed this jump before.", 230, 0, 0)
                elseif not self.currentStuntJump.hitEndTrigger then
                    outputChatBox("You've not hit the end trigger.", 230, 0, 0)
                end
            end

            self.stuntJumpState = "start"
            self.currentStuntJump = nil
        end
    end,

    updateCameraDuringStuntJump = function(self)
        if self.currentStuntJump then
            local cam = self.currentStuntJump.camera
            if cam and cam.x then
                local pos = localPlayer.position
                setCameraMatrix(cam.x, cam.y, cam.z, pos.x, pos.y, pos.z)
            end
        end
    end,
}

Jump = c_Jump()
