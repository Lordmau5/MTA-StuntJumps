StuntJumps = {
    jumps = {},
}

function StuntJumps.add(id, startBox, endBox, camera, reward)
    local jump = StuntJump(id, startBox, endBox, camera, reward)

    table.insert(StuntJumps.jumps, jump)
end

function StuntJumps.getJumpForStartBox(x, y, z)
    for _, jump in ipairs(StuntJumps.jumps) do
        if jump:isInStartBox(x, y, z) then
            return jump
        end
    end
    return nil
end

function StuntJumps.isInEndTrigger(jump, x, y, z)
    if not jump or not jump.endBox then
        return false
    end

    return jump:isInEndBox(x, y, z)
end
