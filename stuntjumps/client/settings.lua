local __default_settings = {
    fpsLimit = 60,
    canBeKnockedOffBike = false,
    drawBoundingBoxes = false,
}

class "c_Settings" {
    constructor = function(self)
        self.settings = {
            fpsLimit = __default_settings.fpsLimit,
            canBeKnockedOffBike = __default_settings.canBeKnockedOffBike,
            drawBoundingBoxes = __default_settings.drawBoundingBoxes,
        }

        addEventHandler("onClientResourceStart", resourceRoot, function()
            self:onStart()
        end)
    end,

    onStart = function(self)
        self:load()

        self:updateSettings()
    end,

    updateSettings = function(self)
        setFPSLimit(self:get("fpsLimit"))
        setPedCanBeKnockedOffBike(localPlayer, self:get("canBeKnockedOffBike"))

        MainUI:updateCheckboxes()
    end,

    load = function(self)
        if not File.exists("settings.json") then
            return
        end

        local settingsFile = File.open("settings.json", true)
        if settingsFile then
            local data = settingsFile:read(settingsFile:getSize())
            self.settings = fromJSON(data)
            outputDebugString("Loaded: " .. data)
            settingsFile:close()
        end
    end,

    save = function(self)
        local settingsFile = File.new("settings.json")
        if settingsFile then
            settingsFile:write(toJSON(self.settings))
            settingsFile:close()
        end
    end,

    get = function(self, key)
        if self.settings[key] ~= nil then
            return self.settings[key]
        end

        return __default_settings[key]
    end,

    set = function(self, key, value)
        if __default_settings[key] == nil then
            return false
        end

        self.settings[key] = value
        outputDebugString("Set: " .. key .. " to " .. tostring(self.settings[key]))

        self:updateSettings()
        self:save()

        return true
    end,
}

Settings = c_Settings()
