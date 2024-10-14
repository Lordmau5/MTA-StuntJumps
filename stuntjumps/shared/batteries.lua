-- partial libraries from 1bardesign/batteries for use in this MTA resource
-- https://github.com/1bardesign/batteries
--
-- Copyright 2021 Max Cahill
-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgment in the product documentation would be
--    appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.
-- 
stringx = {}
tablex = {}

-- check if a given string ends with another
-- (without garbage)
function stringx.ends_with(s, suffix)
    local len = #s
    local suffix_len = #suffix
    for i = 0, suffix_len - 1 do
        if string.byte(s, len - i) ~= string.byte(suffix, suffix_len - i) then
            return false
        end
    end
    return true
end

-- collect all values of a keyed table into a sequential table
-- (shallow copy if it's already sequential)
function tablex.values(t)
    local r = {}
    for k, v in pairs(t) do
        table.insert(r, v)
    end
    return r
end
