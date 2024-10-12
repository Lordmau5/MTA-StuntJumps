-- info point / start point to spawn an NRG at, maybe also camera position in the air to preview the jump?
-- also an easy spawn point / setting an active jump to "practice"
-- menu to toggle falling off the bike
-- saving / loading jumps
-- allowing multiple stunt jumps
--
--
local isFreecamActive = false
local isGuiActive = false
local isSelectingBoundingBox = false
local isSelectingEndingBox = false

local corners = {
    first = nil,
    second = nil,
}
local startBoundingBox = nil
local endBoundingBox = nil
local cameraPosition = {}

local activeEditBoundingBox = 0

function isEditModeActive()
    return isFreecamActive
end

function getCameraPosition()
    return cameraPosition
end

function getBoundingBox(firstCorner, secondCorner)
    local minX = math.min(firstCorner.x, secondCorner.x)
    local maxX = math.max(firstCorner.x, secondCorner.x)

    local minY = math.min(firstCorner.y, secondCorner.y)
    local maxY = math.max(firstCorner.y, secondCorner.y)

    local minZ = math.min(firstCorner.z, secondCorner.z)
    local maxZ = math.max(firstCorner.z, secondCorner.z)

    return {
        minX = minX,
        maxX = maxX,
        minY = minY,
        maxY = maxY,
        minZ = minZ,
        maxZ = maxZ,
    }
end

function getStartingBoundingBox()
    if not startBoundingBox then
        return nil -- Return nil if the bounding box hasn't been set
    end

    return getBoundingBox(startBoundingBox.first, startBoundingBox.second)
end

function getEndingBoundingBox()
    if not endBoundingBox then
        return nil -- Return nil if the bounding box hasn't been set
    end

    return getBoundingBox(endBoundingBox.first, endBoundingBox.second)
end

local guiWindow, setupStartBtn, setupEndBtn, setupCameraBtn, closeBtn

-- Toggles freecam mode on and off
function toggleFreecam(mode)
    if mode ~= true and mode ~= false then
        mode = not isFreecamActive
    end

    isFreecamActive = mode

    if isFreecamActive then
        -- Entering freecam, hide player and HUD
        local x, y, z = getCameraMatrix()
        showChat(false)
        setElementFrozen(localPlayer, true)
        setElementAlpha(localPlayer, 0)

        exports.stuntjumps_freecam:setFreecamEnabled(x, y, z)
    else
        -- Leaving freecam, restore normal gameplay view
        setCameraTarget(localPlayer)
        showChat(true)
        setElementFrozen(localPlayer, false)
        closeGui()
        setElementAlpha(localPlayer, 255)
        activeEditBoundingBox = 0

        exports.stuntjumps_freecam:setFreecamDisabled()
    end
end
bindKey("F4", "down", toggleFreecam) -- Toggle freecam with F4

-- Toggles the GUI
function toggleGui()
    if isGuiActive then
        closeGui()
    else
        isSelectingBoundingBox = false
        showGui()
    end
end
bindKey("H", "down", toggleGui) -- Open/close the GUI with H

local current_jump_id = 1
function createAndTeleport(_key, _state, adjust)
    current_jump_id = current_jump_id + adjust
    if current_jump_id < 1 then
        current_jump_id = #StuntJumps.jumps
    elseif current_jump_id > #StuntJumps.jumps then
        current_jump_id = 1
    end

    outputDebugString("Teleporting to jump " .. current_jump_id)
    local jump = StuntJumps.jumps[current_jump_id]

    local startMin = jump.startBox.min

    if isEditModeActive() then
        exports.stuntjumps_freecam:setFreecamDisabled()

        setElementPosition(localPlayer, startMin.x, startMin.y, startMin.z + 10)

        exports.stuntjumps_freecam:setFreecamEnabled(startMin.x, startMin.y, startMin.z + 10)
    else
        setElementPosition(getPedOccupiedVehicle(localPlayer) or localPlayer, startMin.x, startMin.y, startMin.z + 2)
    end

    -- startBoundingBox = jump.startBox
    -- endBoundingBox = jump.endBox

    -- cameraPosition = jump.camera
end
bindKey("9", "down", createAndTeleport, -1)
bindKey("0", "down", createAndTeleport, 1)

-- Create the GUI elements
function createGui()
    guiWindow = guiCreateWindow(0.4, 0.4, 0.2, 0.3, "Editor Options", true)

    setupStartBtn = guiCreateButton(0.1, 0.2, 0.8, 0.15, "Setup Starting Bounding Box", true, guiWindow)
    setupEndBtn = guiCreateButton(0.1, 0.4, 0.8, 0.15, "Setup Ending Bounding Box", true, guiWindow)
    setupCameraBtn = guiCreateButton(0.1, 0.6, 0.8, 0.15, "Setup Camera Position", true, guiWindow)
    closeBtn = guiCreateButton(0.1, 0.8, 0.8, 0.15, "Close", true, guiWindow)

    addEventHandler("onClientGUIClick", setupStartBtn, onSetupStartBoundingBox, false)
    addEventHandler("onClientGUIClick", setupEndBtn, onSetupEndBoundingBox, false)
    addEventHandler("onClientGUIClick", setupCameraBtn, onSetupCameraPosition, false)
    addEventHandler("onClientGUIClick", closeBtn, closeGui, false)

    guiSetVisible(guiWindow, false)

    -- Ped knocked off bike
    setPedCanBeKnockedOffBike(localPlayer, false)
end
addEventHandler("onClientResourceStart", resourceRoot, createGui)

function onClientPlayerDamage()
    cancelEvent()
end
addEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerDamage)

function getActiveEditBoundingBox()
    if activeEditBoundingBox == 1 then
        return startBoundingBox, "start"
    elseif activeEditBoundingBox == 2 then
        return endBoundingBox, "end"
    end

    return nil
end

function updateEditBoundingBox(box, boxType)
    if boxType == "start" then
        startBoundingBox = box
    elseif boxType == "end" then
        endBoundingBox = box
    end
end

-- Show the GUI
function showGui()
    isGuiActive = true
    guiSetVisible(guiWindow, true)
    showCursor(true)
end

-- Close the GUI
function closeGui()
    isGuiActive = false
    guiSetVisible(guiWindow, false)
    showCursor(false)
end

-- Setup starting bounding box
function onSetupStartBoundingBox()
    corners = {
        first = nil,
        second = nil,
    }

    startBoundingBox = nil
    isSelectingEndingBox = false
    closeGui()
    isSelectingBoundingBox = true
    outputDebugString("Select the starting bounding box. Left click to set corners.")
end

-- Setup ending bounding box
function onSetupEndBoundingBox()
    corners = {
        first = nil,
        second = nil,
    }

    endBoundingBox = nil
    isSelectingEndingBox = true
    closeGui()
    isSelectingBoundingBox = true
    outputDebugString("Select the ending bounding box. Left click to set corners.")
end

-- Setup camera position
function onSetupCameraPosition()
    closeGui()

    -- Set the camera position
    local camX, camY, camZ, lookAtX, lookAtY, lookAtZ = getCameraMatrix()
    cameraPosition = {
        x = camX,
        y = camY,
        z = camZ,
        lookAtX = lookAtX,
        lookAtY = lookAtY,
        lookAtZ = lookAtZ,
    }
    outputChatBox("Camera position set: " .. camX .. ", " .. camY .. ", " .. camZ)
end

local screenWidth, screenHeight = guiGetScreenSize()
local crosshairTexture = dxCreateTexture("crosshair.png")

function updatePlayerPosition()
    if not isFreecamActive then
        return
    end

    local camX, camY, camZ = getCameraMatrix()
    setElementPosition(localPlayer, camX, camY, camZ)

    -- Draw crosshair
    dxDrawImage(screenWidth / 2 - 25, screenHeight / 2 - 25, 50, 50, crosshairTexture)
end
addEventHandler("onClientRender", root, updatePlayerPosition)

-- Bounding box corner updater
function determineBoundingBoxCorners(firstCorner, secondCorner)
    if firstCorner.z > secondCorner.z then
        firstCorner.z = firstCorner.z + 1

        local temp = secondCorner
        secondCorner = firstCorner
        firstCorner = temp
    else
        secondCorner.z = secondCorner.z + 1
    end

    return {
        first = firstCorner,
        second = secondCorner,
    }
end

-- Handle left-click selections for bounding boxes or camera position
function handleSelection(button)
    if not isSelectingBoundingBox then
        return
    end

    if button == "mouse2" then
        if corners.first ~= nil then
            corners.first = nil
            return
        end
        return
    end

    if button ~= "mouse1" then
        return
    end

    local hitX, hitY, hitZ = getCameraAimPoint()
    if not hitX or not hitY or not hitZ then
        outputDebugString("Hit point not found.")
        return
    end

    outputDebugString(hitX .. ":" .. hitY .. ":" .. hitZ)
    if not corners.first then
        corners.first = {
            x = hitX,
            y = hitY,
            z = hitZ,
        }
        outputChatBox("First corner set.")
    elseif not corners.second then
        corners.second = {
            x = hitX,
            y = hitY,
            z = hitZ,
        }

        if isSelectingEndingBox then
            endBoundingBox = determineBoundingBoxCorners(corners.first, corners.second)
        else
            startBoundingBox = determineBoundingBoxCorners(corners.first, corners.second)
        end

        isSelectingBoundingBox = false
        corners = {
            first = nil,
            second = nil,
        }

        outputChatBox("Second corner set. Bounding box completed.")
    end
end

local function onKeyPressed(button, press)
    if not press then
        return
    end

    if button == "1" then
        activeEditBoundingBox = activeEditBoundingBox == 1 and 0 or 1
    elseif button == "2" then
        activeEditBoundingBox = activeEditBoundingBox == 2 and 0 or 2
    elseif button == "mouse1" or button == "mouse2" then
        handleSelection(button)
    end
end
addEventHandler("onClientKey", root, onKeyPressed)

-- Get the point where the camera is aiming at the ground
function getCameraAimPoint()
    local camX, camY, camZ = getCameraMatrix()
    local screenWidth, screenHeight = guiGetScreenSize()
    local targetX, targetY, targetZ = getWorldFromScreenPosition(screenWidth / 2, screenHeight / 2, 1000)

    local hit, hitX, hitY, hitZ = processLineOfSight(camX, camY, camZ, targetX, targetY, targetZ, true, false, false,
        true, false, false, false, false)

    if hit then
        return hitX, hitY, hitZ + 0.1
    end

    return nil
end

local isBoundingBoxAlphaVisible = true
function updateAlphaRenderForEdit()
    isBoundingBoxAlphaVisible = not isBoundingBoxAlphaVisible
end
setTimer(updateAlphaRenderForEdit, 500, 0)

function renderAllBoundingBoxes()
    for id, jump in ipairs(StuntJumps.jumps) do
        repeat
            if jump.done then
                break
            end

            -- Draw start box
            drawBoundingBox(jump.startBox.min, jump.startBox.max, tocolor(10, 10, 10, 255), tocolor(0, 200, 0, 100))

            local endColor = tocolor(0, 200, 200, 100)

            local currentJump = Jump.getCurrentStuntJump()
            if currentJump and id == currentJump.id and currentJump.hitEndTrigger then
                endColor = tocolor(0, 200, 0, 100)
            end

            -- Draw end box
            drawBoundingBox(jump.endBox.min, jump.endBox.max, tocolor(10, 10, 10, 255), endColor)
        until true
    end
end
addEventHandler("onClientPreRender", root, renderAllBoundingBoxes)

-- Render bounding box during selection
function renderBoundingBox()
    if isSelectingBoundingBox and corners.first then
        -- Draw temporary bounding box while selecting the second corner
        local hitX, hitY, hitZ = getCameraAimPoint()
        if hitX and hitY and hitZ then
            local tempCorner = {
                x = hitX,
                y = hitY,
                z = hitZ,
            }

            drawBoundingBox(corners.first, tempCorner, tocolor(10, 10, 10, 255), tocolor(0, 0, 200, 100)) -- Red outline, blue transparent fill
        end
    end

    if startBoundingBox then
        local visible = getActiveEditBoundingBox() ~= startBoundingBox or isBoundingBoxAlphaVisible

        -- Draw finalized bounding box
        drawBoundingBox(startBoundingBox.first, startBoundingBox.second, tocolor(10, 10, 10, 255),
            tocolor(0, 200, 0, visible and 100 or 0))
    end

    if endBoundingBox then
        local visible = getActiveEditBoundingBox() ~= endBoundingBox or isBoundingBoxAlphaVisible

        -- Draw finalized bounding box
        drawBoundingBox(endBoundingBox.first, endBoundingBox.second, tocolor(10, 10, 10, 255),
            tocolor(0, 200, 200, visible and 100 or 0))
    end
end
addEventHandler("onClientPreRender", root, renderBoundingBox)

-- Draw the bounding box (outline and fill)
function drawBoundingBox(corner1, corner2, outlineColor, fillColor)
    local x1, y1, z1 = corner1.x, corner1.y, corner1.z
    local x2, y2, z2 = corner2.x, corner2.y, corner2.z

    -- Calculate corners of the bounding box
    local corners = {
        {
            x1,
            y1,
            z1,
        },
        {
            x2,
            y1,
            z1,
        },
        {
            x2,
            y2,
            z1,
        },
        {
            x1,
            y2,
            z1,
        }, -- Lower corners
        {
            x1,
            y1,
            z2,
        },
        {
            x2,
            y1,
            z2,
        },
        {
            x2,
            y2,
            z2,
        },
        {
            x1,
            y2,
            z2,
        }, -- Upper corners
    }

    local outlineThickness = 2
    -- Draw the thick lines for the bounding box outline
    for i = 1, 4 do
        dxDrawLine3D(corners[i][1], corners[i][2], corners[i][3], corners[i % 4 + 1][1], corners[i % 4 + 1][2],
            corners[i % 4 + 1][3], outlineColor, outlineThickness) -- Bottom
        dxDrawLine3D(corners[i + 4][1], corners[i + 4][2], corners[i + 4][3], corners[i % 4 + 5][1],
            corners[i % 4 + 5][2], corners[i % 4 + 5][3], outlineColor, outlineThickness) -- Top
        dxDrawLine3D(corners[i][1], corners[i][2], corners[i][3], corners[i + 4][1], corners[i + 4][2],
            corners[i + 4][3], outlineColor, outlineThickness) -- Verticals
    end

    -- Draw the faces of the bounding box
    dxDrawTriangleFan(corners[1], corners[2], corners[3], corners[4], fillColor) -- Bottom face
    dxDrawTriangleFan(corners[5], corners[6], corners[7], corners[8], fillColor) -- Top face
    dxDrawTriangleFan(corners[1], corners[2], corners[6], corners[5], fillColor) -- South face
    dxDrawTriangleFan(corners[2], corners[3], corners[7], corners[6], fillColor) -- East face
    dxDrawTriangleFan(corners[3], corners[4], corners[8], corners[7], fillColor) -- North face
    dxDrawTriangleFan(corners[4], corners[1], corners[5], corners[8], fillColor) -- West face
end

function dxDrawTriangleFan(c1, c2, c3, c4, c)
    local primitive = {
        {
            c1[1],
            c1[2],
            c1[3],
            c, -- Vertex 1
        },
        {
            c2[1],
            c2[2],
            c2[3],
            c, -- Vertex 2
        },
        {
            c3[1],
            c3[2],
            c3[3],
            c, -- Vertex 3
        },
        {
            c4[1],
            c4[2],
            c4[3],
            c, -- Vertex 4
        },
    }

    dxDrawPrimitive3D("trianglefan", false, unpack(primitive))
end

-- Reset the bounding boxes
function resetBoundingBoxes()
    startBoundingBox = nil
    endBoundingBox = nil
end

-- Reset camera position
function resetCameraPosition()
    cameraPosition = {}
end

-- Clear all data on resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    resetBoundingBoxes()
    resetCameraPosition()
end)

