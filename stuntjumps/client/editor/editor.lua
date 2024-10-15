-- info point / start point to spawn an NRG at, maybe also camera position in the air to preview the jump?
-- also an easy spawn point / setting an active jump to "practice"
-- menu to toggle falling off the bike
--
class "c_Editor" {
    constructor = function(self)
        self.editModeActive = false
        self.guiActive = false
        self.isSelectingBoundingBox = false
        self.isSelectingEndingBox = false

        self.crosshairTexture = dxCreateTexture("assets/images/crosshair.png")

        self.gui = {
            isActive = false,
            window = nil,
            setupStartBtn = nil,
            setupEndBtn = nil,
            setupCameraBtn = nil,
            closeBtn = nil,
        }

        self.corners = {
            first = nil,
            second = nil,
        }

        self.startBoundingBox = nil
        self.endBoundingBox = nil

        self.cameraPosition = {}
        self.activeEditBoundingBox = {}
        self.isBoundingBoxAlphaVisible = true

        ---

        addEventHandler("onClientResourceStart", resourceRoot, function()
            self:onStart()
        end)

        addEventHandler("onClientPlayerDamage", localPlayer, function()
            self:onClientPlayerDamage()
        end)

        addEventHandler("onClientRender", root, function()
            self:updatePlayerPosition()
        end)

        -- Render bounding box during selection
        addEventHandler("onClientPreRender", root, function()
            self:renderEditBoundingBox()
        end)

        addEventHandler("onClientKey", root, function(button, press)
            self:onKeyPressed(button, press)
        end)

        setTimer(function()
            self:updateAlphaRenderForEdit()
        end, 500, 0)

        bindKey("F4", "down", function()
            self:toggleEditMode()
        end) -- Toggle freecam with F4

        bindKey("H", "down", function()
            self:toggleGui()
        end) -- Open/close the GUI with H
    end,

    onStart = function(self)
        self.gui.window = guiCreateWindow(0.4, 0.4, 0.2, 0.3, "Editor Options", true)

        self.gui.setupStartBtn = guiCreateButton(0.1, 0.2, 0.8, 0.15, "Setup Starting Bounding Box", true,
            self.gui.window)
        self.gui.setupEndBtn = guiCreateButton(0.1, 0.4, 0.8, 0.15, "Setup Ending Bounding Box", true, self.gui.window)
        self.gui.setupCameraBtn = guiCreateButton(0.1, 0.6, 0.8, 0.15, "Setup Camera Position", true, self.gui.window)
        self.gui.closeBtn = guiCreateButton(0.1, 0.8, 0.8, 0.15, "Close", true, self.gui.window)

        addEventHandler("onClientGUIClick", self.gui.setupStartBtn, function()
            self:onSetupStartBoundingBox()
        end, false)
        addEventHandler("onClientGUIClick", self.gui.setupEndBtn, function()
            self:onSetupEndBoundingBox()
        end, false)
        addEventHandler("onClientGUIClick", self.gui.setupCameraBtn, function()
            self:onSetupCameraPosition()
        end, false)
        addEventHandler("onClientGUIClick", self.gui.closeBtn, function()
            self:closeGui()
        end, false)

        guiSetVisible(self.gui.window, false)

        -- Ped knocked off bike
        setPedCanBeKnockedOffBike(localPlayer, false)
    end,

    onClientPlayerDamage = function(self)
        cancelEvent()
    end,

    updatePlayerPosition = function(self)
        if not self.editModeActive then
            return
        end

        local camX, camY, camZ = getCameraMatrix()
        setElementPosition(localPlayer, camX, camY, camZ)

        -- Draw crosshair
        local screenWidth, screenHeight = guiGetScreenSize()
        dxDrawImage(screenWidth / 2 - 25, screenHeight / 2 - 25, 50, 50, self.crosshairTexture)
    end,

    isEditModeActive = function(self)
        return self.editModeActive
    end,

    getCameraPosition = function(self)
        return self.cameraPosition
    end,

    getStartingBoundingBox = function(self)
        if not self.startBoundingBox then
            return nil -- Return nil if the bounding box hasn't been set
        end

        return getBoundingBox(startBoundingBox.first, startBoundingBox.second)
    end,

    getEndingBoundingBox = function(self)
        if not self.endBoundingBox then
            return nil -- Return nil if the bounding box hasn't been set
        end

        return getBoundingBox(endBoundingBox.first, endBoundingBox.second)
    end,

    -- Toggles freecam mode on and off
    toggleEditMode = function(self, mode)
        if mode ~= true and mode ~= false then
            mode = not self.editModeActive
        end

        self.editModeActive = mode

        if self.editModeActive then
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
            self:closeGui()
            setElementAlpha(localPlayer, 255)
            self.activeEditBoundingBox = 0

            exports.stuntjumps_freecam:setFreecamDisabled()
        end
    end,

    -- Toggles the GUI
    toggleGui = function(self)
        if not self.editModeActive then
            self:closeGui()
            return
        end

        if self.gui.isActive then
            self:closeGui()
        else
            self.isSelectingBoundingBox = false
            self:showGui()

            self.activeEditBoundingBox = 0
        end
    end,

    -- Show the GUI
    showGui = function(self)
        self.gui.isActive = true
        guiSetVisible(self.gui.window, true)
        showCursor(true)
    end,

    -- Close the GUI
    closeGui = function(self)
        self.gui.isActive = false
        guiSetVisible(self.gui.window, false)
        showCursor(false)
    end,

    -- Setup starting bounding box
    onSetupStartBoundingBox = function(self)
        self.corners = {
            first = nil,
            second = nil,
        }

        self.startBoundingBox = nil
        self.isSelectingEndingBox = false
        self:closeGui()
        self.isSelectingBoundingBox = true
        outputDebugString("Select the starting bounding box. Left click to set corners.")
    end,

    -- Setup ending bounding box
    onSetupEndBoundingBox = function(self)
        self.corners = {
            first = nil,
            second = nil,
        }

        self.endBoundingBox = nil
        self.isSelectingEndingBox = true
        self:closeGui()
        self.isSelectingBoundingBox = true
        outputDebugString("Select the ending bounding box. Left click to set corners.")
    end,

    -- Setup camera position
    onSetupCameraPosition = function(self)
        self:closeGui()

        -- Set the camera position
        local camX, camY, camZ, lookAtX, lookAtY, lookAtZ = getCameraMatrix()
        self.cameraPosition = {
            x = camX,
            y = camY,
            z = camZ,
            lookAtX = lookAtX,
            lookAtY = lookAtY,
            lookAtZ = lookAtZ,
        }
        outputChatBox("Camera position set: " .. camX .. ", " .. camY .. ", " .. camZ)
    end,

    -- Bounding box corner updater
    finalizeBoundingBox = function(self)
        if self.corners.first.z > self.corners.second.z then
            self.corners.first.z = self.corners.first.z + 1

            local temp = self.corners.second
            self.corners.second = self.corners.first
            self.corners.first = temp
        else
            self.corners.second.z = self.corners.second.z + 1
        end

        return BoundingBox.fromCorners(self.corners.first, self.corners.second)
    end,

    -- Get the point where the camera is aiming at the ground
    getCameraAimPoint = function(self)
        local camX, camY, camZ = getCameraMatrix()
        local screenWidth, screenHeight = guiGetScreenSize()
        local targetX, targetY, targetZ = getWorldFromScreenPosition(screenWidth / 2, screenHeight / 2, 1000)

        local hit, hitX, hitY, hitZ = processLineOfSight(camX, camY, camZ, targetX, targetY, targetZ, true, false,
            false, true, false, false, false, false)

        if hit then
            return hitX, hitY, hitZ + 0.1
        end

        return nil
    end,

    -- Handle left-click selections for bounding boxes or camera position
    handleSelection = function(self, button)
        if not self.isSelectingBoundingBox then
            return
        end

        if button == "mouse2" then
            if self.corners.first ~= nil then
                self.corners.first = nil
                return
            end
            return
        end

        if button ~= "mouse1" then
            return
        end

        local hitX, hitY, hitZ = self:getCameraAimPoint()
        if not hitX or not hitY or not hitZ then
            outputDebugString("Hit point not found.")
            return
        end

        outputDebugString(hitX .. ":" .. hitY .. ":" .. hitZ)
        if not self.corners.first then
            self.corners.first = {
                x = hitX,
                y = hitY,
                z = hitZ,
            }
            outputChatBox("First corner set.")
        elseif not self.corners.second then
            self.corners.second = {
                x = hitX,
                y = hitY,
                z = hitZ,
            }

            if self.isSelectingEndingBox then
                self.endBoundingBox = self:finalizeBoundingBox()
            else
                self.startBoundingBox = self:finalizeBoundingBox()
            end

            self.isSelectingBoundingBox = false
            self.corners = {
                first = nil,
                second = nil,
            }

            outputChatBox("Second corner set. Bounding box completed.")
        end
    end,

    onKeyPressed = function(self, button, press)
        if not press then
            return
        end

        if button == "1" then
            self.activeEditBoundingBox = self.activeEditBoundingBox == 1 and 0 or 1
        elseif button == "2" then
            self.activeEditBoundingBox = self.activeEditBoundingBox == 2 and 0 or 2
        elseif button == "mouse1" or button == "mouse2" then
            self:handleSelection(button)
        end
    end,

    renderEditBoundingBox = function(self)
        if self.isSelectingBoundingBox and self.corners.first then
            -- Draw temporary bounding box while selecting the second corner
            local hitX, hitY, hitZ = self:getCameraAimPoint()
            if hitX and hitY and hitZ then
                local tempCorner = {
                    x = hitX,
                    y = hitY,
                    z = hitZ,
                }

                BoundingBoxRenderer:drawBoundingBox(self.corners.first, tempCorner, tocolor(10, 10, 10, 255),
                    tocolor(0, 0, 200, 100)) -- Red outline, blue transparent fill
            end
        end

        if self.startBoundingBox then
            local visible = self:getActiveEditBoundingBox() ~= self.startBoundingBox or self.isBoundingBoxAlphaVisible

            -- Draw finalized bounding box
            BoundingBoxRenderer:drawBoundingBox(self.startBoundingBox.min, self.startBoundingBox.max,
                tocolor(10, 10, 10, 255), tocolor(0, 200, 0, visible and 100 or 0))
        end

        if self.endBoundingBox then
            local visible = self:getActiveEditBoundingBox() ~= self.endBoundingBox or self.isBoundingBoxAlphaVisible

            -- Draw finalized bounding box
            BoundingBoxRenderer:drawBoundingBox(self.endBoundingBox.min, self.endBoundingBox.max,
                tocolor(10, 10, 10, 255), tocolor(0, 200, 200, visible and 100 or 0))
        end
    end,

    getActiveEditBoundingBox = function(self)
        if self.activeEditBoundingBox == 1 then
            return self.startBoundingBox, "start"
        elseif self.activeEditBoundingBox == 2 then
            return self.endBoundingBox, "end"
        end

        return nil
    end,

    updateEditBoundingBox = function(self, box, boxType)
        if boxType == "start" then
            self.startBoundingBox = box
        elseif boxType == "end" then
            self.endBoundingBox = box
        end
    end,

    updateAlphaRenderForEdit = function(self)
        self.isBoundingBoxAlphaVisible = not self.isBoundingBoxAlphaVisible
    end,
}

Editor = c_Editor()

-- local current_jump_id = 1
-- function createAndTeleport(_key, _state, adjust)
--     current_jump_id = current_jump_id + adjust
--     if current_jump_id < 1 then
--         current_jump_id = #StuntJumps:get("gta").jumps
--     elseif current_jump_id > #StuntJumps:get("gta").jumps then
--         current_jump_id = 1
--     end

--     outputDebugString("Teleporting to jump " .. current_jump_id)
--     local jump = StuntJumps:get("gta").jumps[current_jump_id]

--     local startMin = jump.startBox.min

--     if isEditModeActive() then
--         exports.stuntjumps_freecam:setFreecamDisabled()

--         setElementPosition(localPlayer, startMin.x, startMin.y, startMin.z + 10)

--         exports.stuntjumps_freecam:setFreecamEnabled(startMin.x, startMin.y, startMin.z + 10)
--     else
--         setElementPosition(getPedOccupiedVehicle(localPlayer) or localPlayer, startMin.x, startMin.y, startMin.z + 2)
--     end

--     -- startBoundingBox = jump.startBox
--     -- endBoundingBox = jump.endBox

--     -- cameraPosition = jump.camera
-- end
-- bindKey("9", "down", createAndTeleport, -1)
-- bindKey("0", "down", createAndTeleport, 1)
