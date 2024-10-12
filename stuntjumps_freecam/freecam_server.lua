function setPlayerFreecamEnabled(player, x, y, z, dontChangeFixedMode)
    return triggerClientEvent(player, "doSetFreecamEnabled", root, x, y, z, dontChangeFixedMode)
end

function setPlayerFreecamDisabled(player, dontChangeFixedMode)
    return triggerClientEvent(player, "doSetFreecamDisabled", root, dontChangeFixedMode)
end

function setPlayerFreecamOption(player, theOption, value)
    return triggerClientEvent(player, "doSetFreecamOption", root, theOption, value)
end

function isPlayerFreecamEnabled(player)
    return getElementData(player, "freecam:state")
end

function enableFreecam(player)
    if (not isPlayerFreecamEnabled(player)) then
        local x, y, z = getElementPosition(player)
        setPlayerFreecamEnabled(player, x, y, z)
    else
        setPlayerFreecamDisabled(player)
    end
end
-- addCommandHandler ('freecam', enableFreecam) 
