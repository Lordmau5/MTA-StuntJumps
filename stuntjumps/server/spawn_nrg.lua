local playerVehicles = {}

function spawnNRG500()
    if getElementType(source) ~= "player" then
        return
    end

    local x, y, z = getElementPosition(source)
    local vehicle = createVehicle(522, x, y, z) -- 522 is the model ID for NRG-500
    setElementRotation(vehicle, getElementRotation(source))
    warpPedIntoVehicle(source, vehicle)

    -- setElementCollidableWith(vehicle, player, false) -- Prevents player from falling off
    setVehicleDamageProof(vehicle, true)
    setVehicleEngineState(vehicle, true)

    if playerVehicles[source] then
        destroyElement(playerVehicles[source])
    end

    playerVehicles[source] = vehicle
end
addEvent("spawnNRG500", true)
addEventHandler("spawnNRG500", root, spawnNRG500)
