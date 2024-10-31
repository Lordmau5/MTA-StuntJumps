---@class JSON: Class
JSON = class()

function JSON.read_file(path)
	local file = File.open(path, true)
	if file then
		local data = file:read(file:getSize())
		file:close()

		return fromJSON(data)
	end

	return nil
end

function JSON.write_file(path, data)
	local file = File.new(path, true)
	if file then
		file:write(toJSON(data))
		file:close()

		return true
	end

	return false
end
