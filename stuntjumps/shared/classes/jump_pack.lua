class "JumpPack" {
    constructor = function(self, name, jumps)
        self.name = name
        self.jumps = {}
        self.active = true

        if jumps ~= nil then
            for _, jump in pairs(jumps) do
                self:add(jump.id, jump.startBox, jump.endBox, jump.camera, jump.reward)
            end
        end
    end,

    destructor = function(self)
        for _, jump in pairs(self.jumps) do
            jump:destroyBlip()
        end
    end,

    import = function(self, json_data)
        self.jumps = {}

        local decodedData = fromJSON(json_data)
        for _, jumpData in pairs(decodedData) do
            self:add(jumpData.id, jumpData.startBox, jumpData.endBox, jumpData.camera, jumpData.reward)
        end
    end,

    importFromFile = function(self)
        local jumpsFile = File.open("jump_packs/" .. self.name .. ".json", true)
        if jumpsFile then
            local data = jumpsFile:read(jumpsFile:getSize())
            self:import(data)
            jumpsFile:close()
        end
    end,

    export = function(self)
        local exportTable = {}
        for id, jump in pairs(self.jumps) do
            exportTable[id] = {
                id = jump.id,
                startBox = jump.startBox,
                endBox = jump.endBox,
                camera = jump.camera,
                reward = jump.reward,
            }
        end

        return toJSON(exportTable, true)
    end,

    exportToFile = function(self)
        local jumpsFile = File.new("jump_packs/" .. self.name .. ".json")
        if jumpsFile then
            jumpsFile:write(self:export())
            jumpsFile:close()
        end
    end,

    clear = function(self)
        self.jumps = {}
    end,

    setupBlips = function(self)
        for _, jump in pairs(self.jumps) do
            jump:setupBlip()
        end
    end,

    isActive = function(self)
        return self.active
    end,

    setActive = function(self, active)
        if active ~= true and active ~= false then
            active = true
        end

        self.active = active
    end,

    add = function(self, id, startBox, endBox, camera, reward)
        if self.jumps[id] ~= nil then
            return false
        end

        local jump = StuntJump(id, startBox, endBox, camera, reward)

        self.jumps[id] = jump

        return jump
    end,

    get = function(self, id)
        return self.jumps[id]
    end,

    getCount = function(self)
        return #tablex.values(self.jumps)
    end,

    getJumpForStartBox = function(self, x, y, z)
        for _, jump in pairs(self.jumps) do
            if jump:isInStartBox(x, y, z) then
                return jump
            end
        end

        return nil
    end,
}
