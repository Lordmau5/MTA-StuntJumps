function onClientResourceStart()
    setGameSpeed(1)
    setFPSLimit(60)

    setPlayerHudComponentVisible("all", false)

    setPlayerHudComponentVisible("radar", true)

    setPedCanBeKnockedOffBike(localPlayer, false)
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
