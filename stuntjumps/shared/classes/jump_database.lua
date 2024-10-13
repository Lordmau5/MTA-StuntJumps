class "c_StuntJumps" {
    constructor = function(self)
        self.jumps = {}
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

StuntJumps = c_StuntJumps()
