---@class ServerInit: Class
ServerInit = class()

function ServerInit:init()
	addEventHandler("onResourceStart", resourceRoot, function()
		self:onStart()
	end)
end

function ServerInit:onStart()
	setTimer(function()
		StuntJumps:load()
	end, 1000, 1)
end

ServerInit:new()
