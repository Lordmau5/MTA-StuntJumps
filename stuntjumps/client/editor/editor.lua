-- info point / start point to spawn an NRG at, maybe also camera position in the air to preview the jump?
-- also an easy spawn point / setting an active jump to "practice"
-- menu to toggle falling off the bike
-- GUI checkbox to save the camera position with lookAtX, Y and Z (or if it should follow the vehicle / player)
-- list in the GUI to select which jumps to teleport to / edit / add etc.
--
-- reserved "edit" jump and "editor" pack, which are the currently editing one
-- prefix all jump ids with their pack id
--

---@class EditorClass: Class
EditorClass = class()

function EditorClass:init()
	self.editModeActive = false
	self.isSelectingBoundingBox = false
	self.isSelectingEndingBox = false

	self.crosshair = dxCreateRenderTarget(50, 50, true)
	if self.crosshair then
		self:updateCrosshairRender()
	end

	self.ui = {
		isActive = false,
		window = nil,
		tabPanel = nil,
		tabCreate = nil,
		tabEdit = nil,
		setupStartBtn = nil,
		setupEndBtn = nil,
		setupCameraBtn = nil,
		closeBtn = nil,
	}

	self.corners = {
		first = nil,
		second = nil,
	}

	self.startBoundingBox = nil --[[@as BoundingBox|nil]]
	self.endBoundingBox = nil --[[@as BoundingBox|nil]]

	self.cameraPosition = {}
	self.activeEditBoundingBox = {}
	self.isBoundingBoxAlphaVisible = true

	self.jumpPack = StuntJumps:add("editor")
	self.editJump = nil

	--- Debug
	self.current_jump_id = 1
	bindKey("9", "down", function()
		self:createAndTeleport(-1)
	end)
	bindKey("0", "down", function()
		self:createAndTeleport(1)
	end)
	---

	addEventHandler("onClientResourceStart", resourceRoot, function()
		self:onStart()
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
end

function EditorClass:updateCrosshairRender()
	if not self.crosshair then
		return
	end

	dxSetRenderTarget(self.crosshair)
	dxSetBlendMode("modulate_add")

	local texture = dxCreateTexture("assets/images/crosshair.png")
	dxDrawImage(0, 0, 50, 50, texture)

	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function EditorClass:onStart()
	local textColor = 0xFFFFFFFF
	local titleColor = 0xC81448AF

	self.ui.window = dgsCreateWindow(0.4, 0.4, 0.2, 0.3, "Editor", true, textColor, 25, nil, titleColor)

	self.ui.tabPanel = dgsCreateTabPanel(0, 0, 1, 1, true, self.ui.window)
	self.ui.tabCreate = dgsCreateTab("Create", self.ui.tabPanel)
	self.ui.tabEdit = dgsCreateTab("Edit", self.ui.tabPanel)

	self.ui.setupStartBtn = dgsCreateButton(0.1, 0.1, 0.8, 0.15, "Setup Starting Bounding Box", true, self.ui.tabCreate)

	self.ui.setupEndBtn = dgsCreateButton(0.1, 0.3, 0.8, 0.15, "Setup Ending Bounding Box", true, self.ui.tabCreate)
	dgsSetEnabled(self.ui.setupEndBtn, false)

	self.ui.setupCameraBtn = dgsCreateButton(0.1, 0.5, 0.8, 0.15, "Setup Camera Position", true, self.ui.tabCreate)
	dgsSetEnabled(self.ui.setupCameraBtn, false)

	self.ui.closeBtn = dgsCreateButton(
		0.1,
		0.7,
		0.8,
		0.15,
		"Close",
		true,
		self.ui.tabCreate,
		0xFFFFFFFF,
		1,
		1,
		nil,
		nil,
		nil,
		0xC8FF5A5A,
		0xC8FF0000
	)

	addEventHandler("onDgsMouseClickUp", self.ui.setupStartBtn, function()
		self:onSetupStartBoundingBox()
	end, false)
	addEventHandler("onDgsMouseClickUp", self.ui.setupEndBtn, function()
		self:onSetupEndBoundingBox()
	end, false)
	addEventHandler("onDgsMouseClickUp", self.ui.setupCameraBtn, function()
		self:onSetupCameraPosition()
	end, false)
	addEventHandler("onDgsMouseClickUp", self.ui.closeBtn, function()
		self:closeGui()
	end, false)

	dgsCenterElement(self.ui.window)
	dgsSetVisible(self.ui.window, false)
end

function EditorClass:updatePlayerPosition()
	if not self.editModeActive or self.ui.isActive then
		return
	end

	local camX, camY, camZ = getElementPosition(getCamera())
	setElementPosition(localPlayer, camX, camY, camZ)

	-- Draw crosshair
	local screenWidth, screenHeight = guiGetScreenSize()
	dxDrawImage(screenWidth / 2 - 25, screenHeight / 2 - 25, 50, 50, self.crosshair)
end

function EditorClass:isEditModeActive()
	return self.editModeActive
end

function EditorClass:getCameraPosition()
	return self.cameraPosition
end

function EditorClass:getStartingBoundingBox()
	return (self.jump and self.jump.startBox) or self.startBoundingBox
end

function EditorClass:getEndingBoundingBox()
	return (self.jump and self.jump.endBox) or self.endBoundingBox
end

-- Toggles freecam mode on and off
function EditorClass:toggleEditMode(mode)
	if mode ~= true and mode ~= false then
		mode = not self.editModeActive
	end

	self.editModeActive = mode

	if self.editModeActive then
		-- Entering freecam, hide player and HUD
		setElementFrozen(localPlayer, true)
		setElementAlpha(localPlayer, 0)

		local camX, camY, camZ = getElementPosition(getCamera())
		exports.stuntjumps_freecam:setFreecamEnabled(camX, camY, camZ)
	else
		-- Leaving freecam, restore normal gameplay view
		setCameraTarget(localPlayer)
		setElementFrozen(localPlayer, false)
		setElementAlpha(localPlayer, 255)

		self:closeGui()
		self.activeEditBoundingBox = 0

		exports.stuntjumps_freecam:setFreecamDisabled()
	end
end

-- Toggles the GUI
function EditorClass:toggleGui()
	if not self.editModeActive then
		self:closeGui()
		return
	end

	if self.ui.isActive then
		self:closeGui()
	else
		self.isSelectingBoundingBox = false
		self:showGui()

		self.activeEditBoundingBox = 0
	end
end

-- Show the GUI
function EditorClass:showGui()
	self.ui.isActive = true
	dgsSetVisible(self.ui.window, true)
	showCursor(true)
end

-- Close the GUI
function EditorClass:closeGui()
	self.ui.isActive = false
	dgsSetVisible(self.ui.window, false)
	showCursor(false)
end

-- Setup starting bounding box
function EditorClass:onSetupStartBoundingBox()
	self.corners = {
		first = nil,
		second = nil,
	}

	self.startBoundingBox = nil
	self.isSelectingEndingBox = false
	self:closeGui()
	self.isSelectingBoundingBox = true
	outputDebugString("Select the starting bounding box. Left click to set corners.")
end

-- Setup ending bounding box
function EditorClass:onSetupEndBoundingBox()
	self.corners = {
		first = nil,
		second = nil,
	}

	self.endBoundingBox = nil
	self.isSelectingEndingBox = true
	self:closeGui()
	self.isSelectingBoundingBox = true
	outputDebugString("Select the ending bounding box. Left click to set corners.")
end

-- Setup camera position
function EditorClass:onSetupCameraPosition()
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

	-- Jump finalization
	if not self.jump then
		self.jump = self.jumpPack:add("edit", self.startBoundingBox, self.endBoundingBox, self.cameraPosition, 500)
	end

	self.jump.camera = self.cameraPosition
end

-- Bounding box corner updater
function EditorClass:finalizeBoundingBox()
	if self.corners.first.z > self.corners.second.z then
		self.corners.first.z = self.corners.first.z + 1

		local temp = self.corners.second
		self.corners.second = self.corners.first
		self.corners.first = temp
	else
		self.corners.second.z = self.corners.second.z + 1
	end

	return BoundingBox.fromCorners(self.corners.first, self.corners.second)
end

-- Get the point where the camera is aiming at the ground
function EditorClass:getCameraAimPoint()
	local camX, camY, camZ = getElementPosition(getCamera())
	local screenWidth, screenHeight = guiGetScreenSize()
	local targetX, targetY, targetZ = getWorldFromScreenPosition(screenWidth / 2, screenHeight / 2, 1000)

	local hit, hitX, hitY, hitZ = processLineOfSight(
		camX,
		camY,
		camZ,
		targetX,
		targetY,
		targetZ,
		true,
		false,
		false,
		true,
		false,
		false,
		false,
		false
	)

	if hit then
		return hitX, hitY, hitZ + 0.1
	end

	return nil
end

-- Handle left-click selections for bounding boxes or camera position
function EditorClass:handleSelection(button)
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

			if self.jump then
				self.jump.endBox = self.endBoundingBox
			end

			dgsSetEnabled(self.ui.setupCameraBtn, true)
		else
			self.startBoundingBox = self:finalizeBoundingBox()

			if self.jump then
				self.jump.startBox = self.startBoundingBox
			end

			dgsSetEnabled(self.ui.setupEndBtn, true)
		end

		self.isSelectingBoundingBox = false
		self.corners = {
			first = nil,
			second = nil,
		}

		outputChatBox("Second corner set. Bounding box completed.")
	end
end

function EditorClass:onKeyPressed(button, press)
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
end

function EditorClass:renderEditBoundingBox()
	if self.isSelectingBoundingBox and self.corners.first then
		-- Draw temporary bounding box while selecting the second corner
		local hitX, hitY, hitZ = self:getCameraAimPoint()
		if hitX and hitY and hitZ then
			local tempCorner = {
				x = hitX,
				y = hitY,
				z = hitZ,
			}

			BoundingBoxRenderer:drawBoundingBox(
				self.corners.first,
				tempCorner,
				tocolor(10, 10, 10, 255),
				tocolor(0, 0, 200, 100)
			) -- Red outline, blue transparent fill
		end
	end

	if self.startBoundingBox or self.jump then
		local box = self:getStartingBoundingBox()

		local visible = self:getActiveEditBoundingBox() ~= box or self.isBoundingBoxAlphaVisible
		local visibleAlpha = visible and 100 or 0
		if Completions:isJumpCompleted(self.jump) then
			visibleAlpha = visible and 20 or 0
		end

		local startColor = tocolor(0, 200, 0, visibleAlpha)
		if not Jump:isVehicleDrivingJumpSpeed() then
			startColor = tocolor(200, 0, 0, visibleAlpha)
		end

		-- Draw finalized bounding box
		BoundingBoxRenderer:drawBoundingBox(box.min, box.max, tocolor(10, 10, 10, 255), startColor)
	end

	if self.endBoundingBox or self.jump then
		local box = self:getEndingBoundingBox()

		local visible = self:getActiveEditBoundingBox() ~= box or self.isBoundingBoxAlphaVisible
		local visibleAlpha = visible and 100 or 0
		if Completions:isJumpCompleted(self.jump) then
			visibleAlpha = visible and 20 or 0
		end

		local endColor = tocolor(0, 200, 200, visibleAlpha)
		if Jump:getHitEndTrigger(self.jump) then
			endColor = tocolor(0, 200, 0, visibleAlpha)
		end

		-- Draw finalized bounding box
		BoundingBoxRenderer:drawBoundingBox(box.min, box.max, tocolor(10, 10, 10, 255), endColor)
	end
end

function EditorClass:getActiveEditBoundingBox()
	if self.activeEditBoundingBox == 1 then
		return self:getStartingBoundingBox(), "start"
	elseif self.activeEditBoundingBox == 2 then
		return self:getEndingBoundingBox(), "end"
	end

	return nil
end

function EditorClass:updateEditBoundingBox(box, boxType)
	if boxType == "start" then
		self.startBoundingBox = box
	elseif boxType == "end" then
		self.endBoundingBox = box
	end
end

function EditorClass:updateAlphaRenderForEdit()
	self.isBoundingBoxAlphaVisible = not self.isBoundingBoxAlphaVisible
end

function EditorClass:createAndTeleport(adjust)
	self.current_jump_id = self.current_jump_id + adjust
	if self.current_jump_id < 1 then
		self.current_jump_id = #StuntJumps:get("gta").jumps
	elseif self.current_jump_id > #StuntJumps:get("gta").jumps then
		self.current_jump_id = 1
	end

	outputDebugString("Teleporting to jump " .. self.current_jump_id)
	local jump = StuntJumps:get("gta").jumps["gta_" .. self.current_jump_id]

	local startMin = jump.startBox.min

	local element = getPedOccupiedVehicle(localPlayer) or localPlayer
	if self:isEditModeActive() then
		exports.stuntjumps_freecam:setFreecamDisabled()

		setElementPosition(element, startMin.x, startMin.y, startMin.z + 10)

		exports.stuntjumps_freecam:setFreecamEnabled(startMin.x, startMin.y, startMin.z + 10)
	else
		setElementPosition(element, startMin.x, startMin.y, startMin.z + 2)
	end
end

Editor = EditorClass() --[[@as EditorClass]]
