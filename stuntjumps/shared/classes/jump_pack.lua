---@class JumpPack: Class
JumpPack = class()

function JumpPack:init(name, jumps)
	self.id = string.to_kebab_case(name)
	self.name = name
	self.jumps = {} --[=[@as StuntJump[]]=]
	self.active = true

	if jumps ~= nil then
		for _, jump in pairs(jumps) do
			self:add(jump.id, jump.startBox, jump.endBox, jump.camera, jump.reward)
		end
	end
end

function JumpPack:destructor()
	for _, jump in pairs(self.jumps) do
		jump:destroyBlip()
	end
end

function JumpPack:import()
	self.jumps = {}

	local data = JSON.read_file("jump_packs/" .. self.id .. ".json")
	if not data then
		return
	end

	for _, jumpData in pairs(data) do
		self:add(jumpData.id, jumpData.startBox, jumpData.endBox, jumpData.camera, jumpData.reward)
	end
end

function JumpPack:export()
	local exportTable = {
		id = self.id,
		name = self.name,
		jumps = {},
	}
	for id, jump in pairs(self.jumps) do
		exportTable.jumps[id] = {
			id = jump.id,
			startBox = jump.startBox,
			endBox = jump.endBox,
			camera = jump.camera,
			reward = jump.reward,
		}
	end

	return JSON.write_file("jump_packs/" .. self.id .. ".json", exportTable)
end

function JumpPack:clear()
	self.jumps = {}
end

function JumpPack:setupBlips(destroy)
	if not localPlayer then
		return
	end

	destroy = destroy == true

	for _, jump in pairs(self.jumps) do
		if destroy then
			jump:destroyBlip()
		else
			jump:setupBlip()
		end
	end
end

function JumpPack:isActive()
	return self.active
end

function JumpPack:setActive(active)
	if active ~= true and active ~= false then
		active = true
	end

	self.active = active
	self:setupBlips(not self.active)
end

function JumpPack:add(id, startBox, endBox, camera, reward)
	if self.jumps[id] ~= nil then
		return false
	end

	local jump = StuntJump(id, startBox, endBox, camera, reward) --[[@as StuntJump]]

	self.jumps[id] = jump

	return jump
end

function JumpPack:get(id)
	return self.jumps[id]
end

function JumpPack:getCount()
	return #table.values(self.jumps)
end

function JumpPack:getJumpForStartBox(x, y, z)
	for _, jump in pairs(self.jumps) do
		if jump:isInStartBox(x, y, z) then
			return jump
		end
	end

	return nil
end
