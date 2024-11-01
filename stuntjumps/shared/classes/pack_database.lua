---@class StuntJumpsClass: Class
StuntJumpsClass = class()

function StuntJumpsClass:init(...)
	self.packs = {} --[=[@as JumpPack[]]=]
end

function StuntJumpsClass:add(name, jumps)
	local id = string.to_kebab_case(name)

	if self.packs[id] ~= nil then
		return false
	end

	self.packs[id] = JumpPack(name, jumps)
	self.packs[id]:setupBlips()

	return self.packs[id]
end

function StuntJumpsClass:remove(name, delete)
	local id = string.to_kebab_case(name)

	if self.packs[id] == nil then
		return false
	end

	self.packs[id] = nil

	if delete then
		File.delete("jump_packs/" .. id .. ".json")
	end
end

function StuntJumpsClass:get(id)
	return self.packs[id]
end

function StuntJumpsClass:getByName(name)
	for id, pack in pairs(self.packs) do
		if pack.name == name then
			return pack
		end
	end

	return nil
end

function StuntJumpsClass:getAll()
	return self.packs
end

function StuntJumpsClass:getJump(jump_id)
	for _, pack in pairs(self.packs) do
		for id, jump in pairs(pack.jumps) do
			if jump.id == jump_id then
				return jump
			end
		end
	end

	return nil
end

function StuntJumpsClass:load()
	outputDebugString("Loading packs...")

	local jump_packs = pathListDir("jump_packs") or {}
	for _, file in pairs(jump_packs) do
		if string.ends_with(file, ".json") then
			local id = string.sub(file, 1, -6)
			outputDebugString("Loading pack '" .. id .. "'")

			-- Get pack name from JSON
			local data = JSON.read_file("jump_packs/" .. id .. ".json")
			if data then
				self:add(data.name, data.jumps)
			end
		end
	end

	outputDebugString("Finished loading " .. #table.values(self.packs) .. " packs")

	self:sendJumpPacksToClient()
end

function StuntJumpsClass:save()
	for id, pack in pairs(self.packs) do
		pack:export()
	end
end

function StuntJumpsClass:sendJumpPacksToClient(client)
	if client == nil or not isElement(client) then
		client = root
	end

	triggerLatentClientEvent(client, "receiveJumpPacks", resourceRoot, self.packs)
end

function StuntJumpsClass:getJumpForStartBox(x, y, z)
	for _, pack in pairs(self.packs) do
		if pack:isActive() then
			local jump = pack:getJumpForStartBox(x, y, z)
			if jump then
				return jump
			end
		end
	end

	return nil
end

StuntJumps = StuntJumpsClass() --[[@as StuntJumpsClass]]
