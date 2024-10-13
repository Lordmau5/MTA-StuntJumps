function onClientResourceStart()
    clearDebugBox()

    setGameSpeed(1)
    setFPSLimit(60)

    setPlayerHudComponentVisible("all", false)

    setPlayerHudComponentVisible("radar", true)

    setPedCanBeKnockedOffBike(localPlayer, false)

    triggerLatentServerEvent("requestJumps", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)

function onClientResourceStop()
    setPlayerHudComponentVisible("all", true)
    setPedCanBeKnockedOffBike(localPlayer, true)
end
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)

function ensureNightTime()
    setTime(0, 0)
end
setTimer(ensureNightTime, 500, 0)

local cooldown = 0
function spawnVehicle(_key, _state, type)
    local currentTime = getTickCount()
    if currentTime < cooldown then
        return
    end

    cooldown = currentTime + 3000

    triggerServerEvent("spawnVehicle", localPlayer, type)
end
bindKey("n", "down", spawnVehicle, "nrg")
bindKey("i", "down", spawnVehicle, "packer")

function resetStuntJumps()
    for _, jump in ipairs(StuntJumps.jumps) do
        jump:setJumpDone(false)
    end
end
bindKey("r", "down", resetStuntJumps)

function receiveJumps(jumps)
    for _, jump in ipairs(jumps) do
        local newJump = StuntJumps:add(jump.id, jump.startBox, jump.endBox, jump.camera, jump.reward)
        newJump:setupBlip()
    end
end
addEvent("receiveJumps", true)
addEventHandler("receiveJumps", root, receiveJumps)
