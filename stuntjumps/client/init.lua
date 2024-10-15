class "ClientInit" {
    constructor = function(self)
        self.spawnCooldown = 0

        addEventHandler("onClientResourceStart", resourceRoot, function()
            self:onStart()
        end)

        addEventHandler("onClientResourceStop", resourceRoot, function()
            self:onStop()
        end)

        setTimer(function()
            self:ensureNightTime()
        end, 500, 0)

        bindKey("n", "down", function()
            self:spawnVehicle("nrg")
        end)
        bindKey("i", "down", function()
            self:spawnVehicle("packer")
        end)

        bindKey("r", "down", function()
            self:resetStuntJumps()
        end)

        addEvent("receiveJumpPacks", true)
        addEventHandler("receiveJumpPacks", resourceRoot, function(packs)
            self:receiveJumpPacks(packs)
        end)

        addEventHandler("onClientPreRender", root, function()
            self:renderAllBoundingBoxes()
        end)
    end,

    onStart = function(self)
        clearDebugBox()

        setGameSpeed(1)
        setFPSLimit(60)

        setPlayerHudComponentVisible("all", false)

        setPlayerHudComponentVisible("radar", true)

        setPedCanBeKnockedOffBike(localPlayer, false)
    end,

    onStop = function(self)
        setPlayerHudComponentVisible("all", true)

        setPedCanBeKnockedOffBike(localPlayer, true)
    end,

    ensureNightTime = function()
        setTime(0, 0)
    end,

    spawnVehicle = function(self, type)
        local currentTime = getTickCount()
        if currentTime < self.spawnCooldown then
            return
        end

        self.spawnCooldown = currentTime + 3000

        triggerServerEvent("spawnVehicle", localPlayer, type)
    end,

    resetStuntJumps = function(self)
        for _, pack in pairs(StuntJumps:getAll()) do
            for _2, jump in pairs(pack.jumps) do
                jump:setJumpDone(false)
            end
        end
    end,

    receiveJumpPacks = function(self, packs)
        outputDebugString("Received " .. #tablex.values(packs) .. " jump packs")
        for name, _pack in pairs(packs) do
            local pack = StuntJumps:add(name, _pack.jumps)
            pack:setupBlips()
        end
    end,

    renderAllBoundingBoxes = function(self)
        local allPacks = StuntJumps:getAll()

        for _, pack in pairs(allPacks) do
            repeat
                if pack.name == "editor" then
                    break
                end

                for _2, jump in pairs(pack.jumps) do
                    repeat
                        if jump.done then
                            break
                        end

                        local startColor = tocolor(0, 200, 0, 100)
                        if not Jump:isVehicleDrivingJumpSpeed() then
                            startColor = tocolor(200, 0, 0, 100)
                        end

                        -- Draw start box
                        BoundingBoxRenderer:drawBoundingBox(jump.startBox.min, jump.startBox.max,
                            tocolor(10, 10, 10, 255), startColor)

                        local endColor = tocolor(0, 200, 200, 100)

                        local currentJump = Jump:getCurrentStuntJump()
                        if currentJump and jump.id == currentJump.id and currentJump.hitEndTrigger then
                            endColor = tocolor(0, 200, 0, 100)
                        end

                        -- Draw end box
                        BoundingBoxRenderer:drawBoundingBox(jump.endBox.min, jump.endBox.max, tocolor(10, 10, 10, 255),
                            endColor)
                    until true
                end
            until true
        end
    end,
}

ClientInit()
