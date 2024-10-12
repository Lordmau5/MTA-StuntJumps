local vehicles = {
    nrg = {},
    packer = {},
}

function spawnVehicle(type)
    if getElementType(source) ~= "player" then
        return
    end

    type = vehicles[type] and type or "nrg"

    local x, y, z = getElementPosition(source)
    local vehicle = createVehicle(type == "packer" and 443 or 522, x, y, z) -- 522 for NRG, 443 for packer
    setElementRotation(vehicle, getElementRotation(source))
    warpPedIntoVehicle(source, vehicle)

    -- setElementCollidableWith(vehicle, player, false) -- Prevents player from falling off
    setVehicleDamageProof(vehicle, true)
    setVehicleEngineState(vehicle, true)

    if vehicles[type][source] then
        destroyElement(vehicles[type][source])
    end

    vehicles[type][source] = vehicle
end
addEvent("spawnVehicle", true)
addEventHandler("spawnVehicle", root, spawnVehicle)
