StuntJumps = {
    jumps = {},
}

function StuntJumps.add(startBox, endBox, camera, reward)
    local jump = {
        id = #StuntJumps.jumps + 1,
        startBox = startBox,
        endBox = endBox,
        camera = camera,
        reward = reward,
        done = false,
    }

    table.insert(StuntJumps.jumps, jump)
end

function StuntJumps.getJumpForStartBox(x, y, z)
    for _, jump in ipairs(StuntJumps.jumps) do
        local startBox = jump.startBox

        if x >= startBox.min.x and x <= startBox.max.x and y >= startBox.min.y and y <= startBox.max.y and z >=
            startBox.min.z and z <= startBox.max.z then
            return jump
        end
    end
    return nil
end

function StuntJumps.isInEndTrigger(jump, x, y, z)
    if not jump or not jump.endBox then
        return false
    end

    local endBox = jump.endBox
    if x >= endBox.min.x and x <= endBox.max.x and y >= endBox.min.y and y <= endBox.max.y and z >= endBox.min.z and z <=
        endBox.max.z then
        return jump
    end
end
