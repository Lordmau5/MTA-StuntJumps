class "c_Completions" {
    constructor = function(self)
        self.completions = {}
        self.editCompleted = false
    end,

    load = function(self)
        local completionFile = File.open("completions.json", true)
        if completionFile then
            local data = completionFile:read(completionFile:getSize())
            self.completions = fromJSON(data)
            completionFile:close()

            for id, state in pairs(self.completions) do
                if state == true then
                    local jump = StuntJumps:getJump(id)
                    if jump then
                        self:setJumpCompleted(jump)
                    end
                end
            end
        end
    end,

    save = function(self)
        local completionFile = File.new("completions.json")
        if completionFile then
            completionFile:write(toJSON(self.completions))
            completionFile:close()
        end
    end,

    isJumpCompleted = function(self, jump)
        if not jump or not jump.id then
            return false
        end

        if jump.id == "edit" then
            return self.editCompleted
        end

        return self.completions[jump.id] == true
    end,

    setJumpCompleted = function(self, jump, completed)
        if not jump or not jump.id then
            return false
        end

        if jump.id == "edit" then
            self.editCompleted = (completed == false and false) or true
            return
        end

        if completed == false then
            self.completions[jump.id] = nil
        else
            self.completions[jump.id] = true
        end

        jump:destroyBlip()

        -- If we reset to not completed, recreate the blip
        if not self.completions[jump.id] then
            jump:setupBlip()
        end

        self:save()

        return true
    end,
}

Completions = c_Completions()