class "ServerInit" {
	constructor = function(self)
		addEventHandler("onResourceStart", resourceRoot, function()
			self:onStart()
		end)
	end,

	onStart = function(self)
		setTimer(function()
			StuntJumps:load()
		end, 1000, 1)
	end,
}

ServerInit()
