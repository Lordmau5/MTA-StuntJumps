---@class CompletionsClass: Class
CompletionsClass = class()

function CompletionsClass:init()
	self.completions = {}
	self.editCompleted = false
end

function CompletionsClass:load()
	if not File.exists("completions.json") then
		return
	end

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
end

function CompletionsClass:save()
	local completionFile = File.new("completions.json")
	if completionFile then
		completionFile:write(toJSON(self.completions))
		completionFile:close()
	end
end

function CompletionsClass:isJumpCompleted(jump)
	if not jump or not jump.id then
		return false
	end

	if jump.id == "edit" then
		return self.editCompleted
	end

	return self.completions[jump.id] == true
end

function CompletionsClass:setJumpCompleted(jump, completed)
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
end

function CompletionsClass:getPackCompletions(pack)
	if not pack or not pack.jumps then
		return 0
	end

	local completed = 0
	for _, jump in pairs(pack.jumps) do
		if self:isJumpCompleted(jump) then
			completed = completed + 1
		end
	end

	return completed
end

function CompletionsClass:resetJumpCompletions(pack)
	if not pack or not pack.jumps then
		return false
	end

	for _, jump in pairs(pack.jumps) do
		self:setJumpCompleted(jump, false)
	end

	return true
end

Completions = CompletionsClass:new() --[[@as CompletionsClass]]
