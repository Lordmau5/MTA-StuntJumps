class "JumpPack" {
	constructor = function(self, name, jumps)
		self.id = string.to_kebab_case(name)
		self.name = name
		self.jumps = {}
		self.active = true

		if jumps ~= nil then
			for _, jump in pairs(jumps) do
				self:add(jump.id, jump.startBox, jump.endBox, jump.camera, jump.reward)
			end
		end
	end,

	destructor = function(self)
		for _, jump in pairs(self.jumps) do
			jump:destroyBlip()
		end
	end,

	import = function(self)
		self.jumps = {}

		local data = json.read_file("jump_packs/" .. self.id .. ".json", true)
		if not data then
			return
		end

		for _, jumpData in pairs(data) do
			self:add(jumpData.id, jumpData.startBox, jumpData.endBox, jumpData.camera, jumpData.reward)
		end
	end,

	export = function(self)
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

		return json.write_file("jump_packs/" .. self.id .. ".json", exportTable)
	end,

	clear = function(self)
		self.jumps = {}
	end,

	setupBlips = function(self, destroy)
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
	end,

	isActive = function(self)
		return self.active
	end,

	setActive = function(self, active)
		if active ~= true and active ~= false then
			active = true
		end

		self.active = active
		self:setupBlips(not self.active)
	end,

	add = function(self, id, startBox, endBox, camera, reward)
		if self.jumps[id] ~= nil then
			return false
		end

		local jump = StuntJump(id, startBox, endBox, camera, reward)

		self.jumps[id] = jump

		return jump
	end,

	get = function(self, id)
		return self.jumps[id]
	end,

	getCount = function(self)
		return #table.values(self.jumps)
	end,

	getJumpForStartBox = function(self, x, y, z)
		for _, jump in pairs(self.jumps) do
			if jump:isInStartBox(x, y, z) then
				return jump
			end
		end

		return nil
	end,
}
