Jump = {}

local currentTime = 0
local timerCheckDelay = 0

-- "start" = start point, "air" = mid air, "land" = end point
local stuntJumpState = "start"
local currentStuntJump = nil

-- Wheel on ground grace period
local groundGracePeriod = 0

function Jump.getCurrentStuntJump()
    return currentStuntJump
end

-- Wheel on ground calculation
local function isAnyWheelOnGround(vehicle)
    for i = 0, 3 do
        if isVehicleWheelOnGround(vehicle, i) then
            groundGracePeriod = currentTime + 500
            return true
        end
    end

    -- Allow a grace period after the vehicle gets airborne to still count as "on ground"
    if currentTime < groundGracePeriod then
        return true
    end

    return false
end

-- If the vehicle is driving the minimum required speed to trigger a Starting stunt jump
-- https://github.com/gta-reversed/gta-reversed-modern/blob/master/source/game_sa/StuntJumpManager.cpp#L111
local function isVehicleDrivingJumpSpeed(vehicle)
    if not vehicle then
        return false
    end

    local vx, vy, vz = getElementVelocity(vehicle)
    return (math.sqrt(vx ^ 2 + vy ^ 2 + vz ^ 2) * 50) >= 20
end

-- If all the conditions are met to trigger the start of a stunt jump
-- https://github.com/gta-reversed/gta-reversed-modern/blob/master/source/game_sa/StuntJumpManager.cpp#L101-L111
local function isStuntJumpStartSatisfied()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then
        return false
    end

    if getVehicleOccupant(vehicle) ~= localPlayer then
        return false
    end

    local vehicleType = getVehicleType(vehicle)
    if vehicleType == "Plane" or vehicleType == "Helicopter" or vehicleType == "Boat" then
        return false
    end

    if not isAnyWheelOnGround(vehicle) then
        return false
    end

    if not isVehicleDrivingJumpSpeed(vehicle) then
        return false
    end

    return true
end

local function getVehiclePosition()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then
        return nil
    end

    return getElementPosition(vehicle)
end

-- Gets the stunt jump for the current position
local function getStuntJumpForPosition()
    local vehX, vehY, vehZ = getVehiclePosition()
    -- Player not in vehicle
    if not vehX then
        return nil
    end

    return StuntJumps.getJumpForStartBox(vehX, vehY, vehZ)
end

local function isFailureStateMet()
    if not currentStuntJump then
        return true
    end

    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then
        return true
    end

    if isAnyWheelOnGround(vehicle) and currentTime > timerCheckDelay then
        return true
    end

    if isElementInWater(vehicle) then
        return true
    end

    return false
end

function gameTick()
    currentTime = getTickCount()

    if stuntJumpState == "start" then
        if not isStuntJumpStartSatisfied() then
            return
        end

        local tempStuntJump = getStuntJumpForPosition()
        if not tempStuntJump then
            return
        end

        setGameSpeed(0.3)

        stuntJumpState = "air"
        currentStuntJump = tempStuntJump
        timerCheckDelay = currentTime + 2000
        currentStuntJump.hitEndTrigger = false

        outputChatBox("Starting stunt jump!")
    elseif stuntJumpState == "air" then
        if not currentStuntJump then
            stuntJumpState = "start"
            return
        end

        local vehX, vehY, vehZ = getVehiclePosition()
        -- Player not in vehicle
        if not vehX then
            stuntJumpState = "land"
            timerCheckDelay = currentTime + 1000
            return
        end

        if StuntJumps.isInEndTrigger(currentStuntJump, vehX, vehY, vehZ) and not currentStuntJump.hitEndTrigger then
            currentStuntJump.hitEndTrigger = true
            playSFX("genrl", 52, 18, false)
        end

        local failed = isFailureStateMet()
        if failed then
            stuntJumpState = "land"
            timerCheckDelay = currentTime + 1000
        end
    elseif stuntJumpState == "land" then
        if currentTime < timerCheckDelay then
            return
        end

        setGameSpeed(1)
        setCameraTarget(localPlayer)

        if currentStuntJump.hitEndTrigger and not currentStuntJump.done then
            currentStuntJump.done = true
            outputChatBox("Completed stunt jump!", 0, 230, 0)
        else
            if currentStuntJump.done then
                outputChatBox("You've already completed this jump before.", 230, 0, 0)
            elseif not currentStuntJump.hitEndTrigger then
                outputChatBox("You've not hit the end trigger.", 230, 0, 0)
            end
        end

        stuntJumpState = "start"
        currentStuntJump = nil
    end
end
setTimer(gameTick, 100, 0)

function updateCameraDuringStuntJump()
    if currentStuntJump then
        local cam = currentStuntJump.camera
        if cam and cam.x then
            local vehX, vehY, vehZ = getElementPosition(localPlayer)
            setCameraMatrix(cam.x, cam.y, cam.z, vehX, vehY, vehZ)
        end
    end
end
addEventHandler("onClientRender", root, updateCameraDuringStuntJump)
