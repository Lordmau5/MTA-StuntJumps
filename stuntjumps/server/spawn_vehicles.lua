class "VehicleSpawner" {
    constructor = function(self)
        self.vehicles = {
            nrg = {},
            packer = {},
        }

        addEvent("spawnVehicle", true)
        addEventHandler("spawnVehicle", root, function(type)
            self:spawnVehicle(client, type)
        end)
    end,

    spawnVehicle = function(self, player, type)
        if getElementType(player) ~= "player" then
            return
        end

        type = self.vehicles[type] and type or "nrg"

        local x, y, z = getElementPosition(player)
        local vehicle = createVehicle(type == "packer" and 443 or 522, x, y, z) -- 522 for NRG, 443 for packer
        setElementRotation(vehicle, getElementRotation(player))
        warpPedIntoVehicle(player, vehicle)

        if self.vehicles[type][player] then
            destroyElement(self.vehicles[type][player])
        end

        self.vehicles[type][player] = vehicle
    end,
}

VehicleSpawner()
