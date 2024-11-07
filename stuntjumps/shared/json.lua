---@class JSON: Class
JSON = class()

function JSON.read_file(path)
	local file = fileOpen(path, true)
	if file then
		local data = fileRead(file, fileGetSize(file))
		fileClose(file)

		return fromJSON(data)
	end

	return nil
end

function JSON.write_file(path, data)
	local file = fileCreate(path)
	if file then
		fileWrite(file, toJSON(data))
		fileClose(file)

		return true
	end

	return false
end
