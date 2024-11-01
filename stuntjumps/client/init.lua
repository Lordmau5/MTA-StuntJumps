-- Load DGS imports
loadstring(exports.dgs:dgsImportFunction())()

---@class ClientInit: Class
ClientInit = class()

function ClientInit:init()
	self.spawnCooldown = 0

	addEventHandler("onClientResourceStart", resourceRoot, function()
		self:onStart()
	end)

	addEventHandler("onClientResourceStop", resourceRoot, function()
		self:onStop()
	end)

	addEventHandler("onClientPlayerDamage", localPlayer, function()
		self:onClientPlayerDamage()
	end)

	addEventHandler("onClientVehicleDamage", localPlayer, function()
		self:onClientVehicleDamage()
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

	addEvent("receiveJumpPacks", true)
	addEventHandler("receiveJumpPacks", resourceRoot, function(packs)
		self:receiveJumpPacks(packs)
	end)

	addEventHandler("onClientPreRender", root, function()
		self:renderAllBoundingBoxes()
	end)
end

function ClientInit:onStart()
	clearDebugBox()

	setGameSpeed(1)

	setPlayerHudComponentVisible("all", false)

	setPlayerHudComponentVisible("radar", true)
end

function ClientInit:onStop()
	setPlayerHudComponentVisible("all", true)

	setPedCanBeKnockedOffBike(localPlayer, true)
end

function ClientInit:onClientPlayerDamage()
	cancelEvent()
end

function ClientInit:onClientVehicleDamage()
	cancelEvent()
end

function ClientInit:ensureNightTime()
	setTime(0, 0)
end

function ClientInit:spawnVehicle(type)
	local currentTime = getTickCount()
	if currentTime < self.spawnCooldown then
		return
	end

	self.spawnCooldown = currentTime + 3000

	triggerServerEvent("spawnVehicle", localPlayer, type)
end

---@param packs JumpPack[]
function ClientInit:receiveJumpPacks(packs)
	outputDebugString("Received " .. #table.values(packs) .. " jump packs")
	for name, _pack in pairs(packs) do
		local pack = StuntJumps:add(name, _pack.jumps)
		if pack then
			pack:setupBlips()
		end
	end

	Completions:load()

	MainUI:updateJumpsTab()
end

function ClientInit:renderAllBoundingBoxes()
	if not Settings:get("drawBoundingBoxes") then
		return
	end

	local allPacks = StuntJumps:getAll()

	for _, pack in pairs(allPacks) do
		repeat
			if pack.name == "editor" or not pack.isActive then
				break
			end

			if not pack:isActive() then
				break
			end

			for _, jump in pairs(pack.jumps) do
				repeat
					if Completions:isJumpCompleted(jump) then
						break
					end

					local startColor = tocolor(0, 200, 0, 100)
					if not Jump:isVehicleDrivingJumpSpeed() then
						startColor = tocolor(200, 0, 0, 100)
					end

					-- Draw start box
					BoundingBoxRenderer:drawBoundingBox(
						jump.startBox.min,
						jump.startBox.max,
						tocolor(10, 10, 10, 255),
						startColor
					)

					local endColor = tocolor(0, 200, 200, 100)

					local currentJump = Jump:getCurrentStuntJump()
					if Jump:getHitEndTrigger() then
						endColor = tocolor(0, 200, 0, 100)
					end

					-- Draw end box
					BoundingBoxRenderer:drawBoundingBox(
						jump.endBox.min,
						jump.endBox.max,
						tocolor(10, 10, 10, 255),
						endColor
					)
				until true
			end
		until true
	end
end

ClientInit()
