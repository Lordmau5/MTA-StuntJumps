-- LUA Class Helper by jonstoler on GitHub
-- https://github.com/jonstoler/class.lua
--
-- Slightly modified to not support getters / setters
-- (otherwise sending data over as a table breaks)

---@class Class
Class = {}

-- default (empty) constructor
function Class:init(...) end

-- create a subclass
function Class:extend(obj)
	obj = obj or {}

	local function copyTable(_table, _destination)
		local table = _table or {}
		local result = _destination or {}

		for k, v in pairs(table) do
			if not result[k] then
				if type(v) == "table" and k ~= "__index" and k ~= "__newindex" then
					result[k] = copyTable(v)
				else
					result[k] = v
				end
			end
		end

		return result
	end

	obj = copyTable(self, obj)

	local mt = {}

	-- create new objects directly, like o = Object()
	mt.__call = function(_self, ...)
		return _self:new(...)
	end

	setmetatable(obj, mt)

	return obj
end

-- set properties outside the constructor or other functions
function Class:set(prop, value)
	if not value and type(prop) == "table" then
		for k, v in pairs(prop) do
			rawset(self, k, v)
		end
	else
		rawset(self, prop, value)
	end
end

-- create an instance of an object with constructor parameters
function Class:new(...)
	local obj = self:extend({})
	if obj.init then
		obj:init(...)
	end
	return obj
end

function class(attr)
	attr = attr or {}
	return Class:extend(attr)
end
