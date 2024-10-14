class "JumpPack" {
    constructor = function(self, name, jumps)
        self.name = name
        self.jumps = {}

        if jumps ~= nil then
            for _, jump in ipairs(jumps) do
                self:add(jump.id, jump.startBox, jump.endBox, jump.camera, jump.reward)
            end
        end
    end,

    destructor = function(self)
        for _, jump in ipairs(self.jumps) do
            jump:destroyBlip()
        end
    end,

    import = function(self, json_data)
        self.jumps = {}

        local decodedData = json.decode(json_data)
        for _, jumpData in ipairs(decodedData) do
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
        for _, jump in ipairs(self.jumps) do
            table.insert(exportTable, {
                id = jump.id,
                startBox = jump.startBox,
                endBox = jump.endBox,
                camera = jump.camera,
                reward = jump.reward,
            })
        end

        return json.encode(exportTable)
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
        for _, jump in ipairs(self.jumps) do
            jump:setupBlip()
        end
    end,

    add = function(self, id, startBox, endBox, camera, reward)
        local jump = StuntJump(id, startBox, endBox, camera, reward)

        table.insert(self.jumps, jump)

        return jump
    end,

    getJumpForStartBox = function(self, x, y, z)
        for _, jump in ipairs(self.jumps) do
            if jump:isInStartBox(x, y, z) then
                return jump
            end
        end

        return nil
    end,
}
