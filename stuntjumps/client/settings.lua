local __default_settings = {
	fpsLimit = 60,
	canBeKnockedOffBike = false,
	drawBoundingBoxes = false,
}

---@class SettingsClass: Class
SettingsClass = class()

function SettingsClass:init()
	self.settings = {
		fpsLimit = __default_settings.fpsLimit,
		canBeKnockedOffBike = __default_settings.canBeKnockedOffBike,
		drawBoundingBoxes = __default_settings.drawBoundingBoxes,
	}

	addEventHandler("onClientResourceStart", resourceRoot, function()
		self:onStart()
	end)
end

function SettingsClass:onStart()
	self:load()

	self:updateSettings()
end

function SettingsClass:updateSettings()
	setFPSLimit(self:get("fpsLimit"))
	setPedCanBeKnockedOffBike(localPlayer, self:get("canBeKnockedOffBike"))

	MainUI:updateCheckboxes()
end

function SettingsClass:load()
	if not File.exists("settings.json") then
		return
	end

	local settingsFile = File.open("settings.json", true)
	if settingsFile then
		local data = settingsFile:read(settingsFile:getSize())
		self.settings = fromJSON(data)
		settingsFile:close()
	end
end

function SettingsClass:save()
	local settingsFile = File.new("settings.json")
	if settingsFile then
		settingsFile:write(toJSON(self.settings))
		settingsFile:close()
	end
end

function SettingsClass:get(key)
	if self.settings[key] ~= nil then
		return self.settings[key]
	end

	return __default_settings[key]
end

function SettingsClass:set(key, value)
	if __default_settings[key] == nil then
		return false
	end

	self.settings[key] = value
	outputDebugString("Set: " .. key .. " to " .. tostring(self.settings[key]))

	self:updateSettings()
	self:save()

	return true
end

Settings = SettingsClass() --[[@as SettingsClass]]
