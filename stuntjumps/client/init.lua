function onClientResourceStart()
    clearDebugBox()

    setGameSpeed(1)
    setFPSLimit(60)

    setPlayerHudComponentVisible("all", false)

    setPlayerHudComponentVisible("radar", true)

    setPedCanBeKnockedOffBike(localPlayer, false)

    -- triggerLatentServerEvent("requestJumps", localPlayer)
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
    for _, jump in ipairs(StuntJumps:getAllJumps()) do
        jump:setJumpDone(false)
    end
end
bindKey("r", "down", resetStuntJumps)

function receiveJumpPacks(packs)
    outputDebugString("Received " .. #tablex.values(packs) .. " jump packs")
    for name, _pack in pairs(packs) do
        local pack = StuntJumps:add(name, _pack.jumps)
        pack:setupBlips()
    end
end
addEvent("receiveJumpPacks", true)
addEventHandler("receiveJumpPacks", resourceRoot, receiveJumpPacks)

function renderAllBoundingBoxes()
    local allJumps = StuntJumps:getAllJumps()

    for _, jump in ipairs(allJumps) do
        repeat
            if jump.done then
                break
            end

            local startColor = tocolor(0, 200, 0, 100)
            if not Jump:isVehicleDrivingJumpSpeed() then
                startColor = tocolor(200, 0, 0, 100)
            end

            -- Draw start box
            BoundingBoxRenderer:drawBoundingBox(jump.startBox.min, jump.startBox.max, tocolor(10, 10, 10, 255),
                startColor)

            local endColor = tocolor(0, 200, 200, 100)

            local currentJump = Jump:getCurrentStuntJump()
            if currentJump and jump.id == currentJump.id and currentJump.hitEndTrigger then
                endColor = tocolor(0, 200, 0, 100)
            end

            -- Draw end box
            BoundingBoxRenderer:drawBoundingBox(jump.endBox.min, jump.endBox.max, tocolor(10, 10, 10, 255), endColor)
        until true
    end
end
addEventHandler("onClientPreRender", root, renderAllBoundingBoxes)
