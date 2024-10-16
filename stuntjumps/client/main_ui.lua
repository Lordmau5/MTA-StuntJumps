class "c_MainUI" {
    constructor = function(self)
        self.textColor = 0xFFFFFFFF
        self.titleColor = 0xC81448AF

        self.ui = {
            window = nil,
            tabPanel = nil,
            tabJumps = nil,
            tabSettings = nil,

            checkboxCanFallOffBike = nil,
            checkbox30FPSLimit = nil,
            checkboxDrawBoundingBoxes = nil,
        }

        addEventHandler("onClientResourceStart", resourceRoot, function()
            self:onStart()
        end)

        bindKey("O", "down", function()
            dgsSetVisible(self.ui.window, not dgsGetVisible(self.ui.window))
            showCursor(dgsGetVisible(self.ui.window))
        end)
    end,

    -- WIP fancy UI
    onStart = function(self)
        local width, height = guiGetScreenSize()
        local uiWidth, uiHeight = 800 / 2560 * width, 500 / 1440 * height
        local centerX, centerY = (width / 2) - (uiWidth / 2), (height / 2) - (uiHeight / 2)

        self.ui.window = dgsCreateWindow(centerX, centerY, uiWidth, uiHeight, "Stunt Jumps", false, self.textColor, 25,
            nil, self.titleColor)
        dgsWindowSetSizable(self.ui.window, false)

        self.ui.tabPanel = dgsCreateTabPanel(0, 0, 1, 1, true, self.ui.window)
        self.ui.tabJumps = dgsCreateTab("Jumps", self.ui.tabPanel)
        self.ui.tabSettings = dgsCreateTab("Settings", self.ui.tabPanel)

        -- TODO: Rework to actually show jumps / jump packs and add a checkbox for every single one
        -- (Or a single checkbox that updates on the right side with an on-click / select for the grid list)
        self.ui.gridListJumpPacks = dgsCreateGridList(0, 0, 0.6, 1, true, self.ui.tabJumps)
        dgsGridListSetSortEnabled(self.ui.gridListJumpPacks, false)

        self.ui.gridListJumpPacks_Column = dgsGridListAddColumn(self.ui.gridListJumpPacks, "Jump Pack", 1)

        self:populateJumpPacks()
        -- for id, player in ipairs(getElementsByType("player")) do
        --     for i = 1, 50 do
        --         local row = dgsGridListAddRow(gridList)
        --         dgsGridListSetItemText(gridList, row, col_id, "Pack " .. tostring(i))
        --     end
        -- end

        self.ui.checkbox30FPSLimit = dgsCreateCheckBox(0.02, 0.02, 0.1, 0.05, "30 FPS Limit", false, true,
            self.ui.tabSettings)
        self.ui.checkboxCanFallOffBike = dgsCreateCheckBox(0.02, 0.07, 0.1, 0.05, "Can Fall Off Bike", false, true,
            self.ui.tabSettings)
        self.ui.checkboxDrawBoundingBoxes = dgsCreateCheckBox(0.02, 0.12, 0.1, 0.05, "Draw Bounding Boxes", false, true,
            self.ui.tabSettings)

        addEventHandler("onDgsMouseClickUp", self.ui.checkbox30FPSLimit, function()
            if source ~= self.ui.checkbox30FPSLimit then
                return
            end

            Settings:set("fpsLimit", dgsCheckBoxGetSelected(source) and 30 or 60)
        end)

        addEventHandler("onDgsMouseClickUp", self.ui.checkboxCanFallOffBike, function()
            if source ~= self.ui.checkboxCanFallOffBike then
                return
            end

            Settings:set("canBeKnockedOffBike", dgsCheckBoxGetSelected(source))
        end)

        addEventHandler("onDgsMouseClickUp", self.ui.checkboxDrawBoundingBoxes, function()
            if source ~= self.ui.checkboxDrawBoundingBoxes then
                return
            end

            Settings:set("drawBoundingBoxes", dgsCheckBoxGetSelected(source))
        end)

        dgsSetVisible(self.ui.window, false)
    end,

    populateJumpPacks = function(self)
        dgsGridListClear(self.ui.gridListJumpPacks)

        for name, pack in pairs(StuntJumps:getAll()) do
            repeat
                if name == "editor" then
                    break
                end

                local row = dgsGridListAddRow(self.ui.gridListJumpPacks)
                dgsGridListSetItemText(self.ui.gridListJumpPacks, row, self.ui.gridListJumpPacks_Column, name)

            until true
        end
    end,

    updateCheckboxes = function(self)
        dgsCheckBoxSetSelected(self.ui.checkbox30FPSLimit, Settings:get("fpsLimit") ~= 60)
        dgsCheckBoxSetSelected(self.ui.checkboxCanFallOffBike, Settings:get("canBeKnockedOffBike"))
        dgsCheckBoxSetSelected(self.ui.checkboxDrawBoundingBoxes, Settings:get("drawBoundingBoxes"))
    end,
}

MainUI = c_MainUI()
