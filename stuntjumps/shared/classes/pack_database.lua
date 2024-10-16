class "c_StuntJumps" {
    constructor = function(self)
        self.packs = {}
    end,

    add = function(self, name, jumps)
        if self.packs[name] ~= nil then
            return false
        end

        self.packs[name] = JumpPack(name, jumps)
        self.packs[name]:setupBlips()

        return self.packs[name]
    end,

    remove = function(self, name, delete)
        if self.packs[name] == nil then
            return false
        end

        self.packs[name] = nil

        if delete then
            File.delete("jump_packs/" .. name .. ".json")
        end
    end,

    get = function(self, name)
        return self.packs[name]
    end,

    getAll = function(self)
        return self.packs
    end,

    getJump = function(self, jump_id)
        for _, pack in pairs(self.packs) do
            for id, jump in pairs(pack.jumps) do
                if jump.id == jump_id then
                    return jump
                end
            end
        end

        return nil
    end,

    load = function(self)
        outputDebugString("Loading packs...")

        local jump_packs = pathListDir("jump_packs") or {}
        for _, file in pairs(jump_packs) do
            if stringx.ends_with(file, ".json") then
                local name = string.sub(file, 1, -6)
                outputDebugString("Loading pack '" .. name .. "'")
                local pack = self:add(name)
                pack:importFromFile()
            end
        end

        outputDebugString("Finished loading " .. #tablex.values(self.packs) .. " packs")

        self:sendJumpPacksToClient()
    end,

    save = function(self)
        for name, pack in pairs(self.packs) do
            pack:exportToFile()
        end
    end,

    sendJumpPacksToClient = function(self, client)
        if client == nil or not isElement(client) then
            client = root
        end

        triggerLatentClientEvent(client, "receiveJumpPacks", resourceRoot, self.packs)
    end,

    getJumpForStartBox = function(self, x, y, z)
        for _, pack in pairs(self.packs) do
            local jump = pack:getJumpForStartBox(x, y, z)
            if jump then
                return jump
            end
        end

        return nil
    end,
}

StuntJumps = c_StuntJumps()
