class "c_MainUI" {
    constructor = function(self)
        self.textColor = 0xFFFFFFFF
        self.titleColor = 0xC81448AF

        self.ui = {
            window = nil,

            checkbox = {},
            tab = {},
        }

        addEventHandler("onClientResourceStart", resourceRoot, function()
            self:onStart()
        end)

        bindKey("O", "down", function()
            local visible = not dgsGetVisible(self.ui.window)

            if visible then
                self.ui.tab["jumps"].updateInfo()
            end

            dgsSetVisible(self.ui.window, visible)
            showCursor(visible)
        end)
    end,

    -- WIP fancy UI
    onStart = function(self)
        local width, height = guiGetScreenSize()
        local uiWidth, uiHeight = 800 / 2560 * width, 500 / 1440 * height

        self.ui.window = dgsCreateWindow(100, 100, uiWidth, uiHeight, "Stunt Jumps", false, self.textColor, 25, nil,
            self.titleColor)
        dgsCenterElement(self.ui.window)
        dgsWindowSetSizable(self.ui.window, false)

        local tabPanel = dgsCreateTabPanel(0, 0, 1, 1, true, self.ui.window)
        self.ui.tab["jumps"] = {
            tab = dgsCreateTab("Jumps", tabPanel),
        }
        self.ui.tab["settings"] = {
            tab = dgsCreateTab("Settings", tabPanel),
        }

        self:buildJumpPacks()

        self.ui.checkbox["30FPSLimit"] = dgsCreateCheckBox(0.02, 0.02, 0.1, 0.05, "30 FPS Limit", false, true,
            self.ui.tab["settings"].tab)
        self.ui.checkbox["canFallOffBike"] = dgsCreateCheckBox(0.02, 0.07, 0.1, 0.05, "Can Fall Off Bike", false, true,
            self.ui.tab["settings"].tab)
        self.ui.checkbox["drawBoundingBoxes"] = dgsCreateCheckBox(0.02, 0.12, 0.1, 0.05, "Draw Bounding Boxes", false,
            true, self.ui.tab["settings"].tab)

        addEventHandler("onDgsMouseClickUp", self.ui.checkbox["30FPSLimit"], function()
            Settings:set("fpsLimit", dgsCheckBoxGetSelected(source) and 30 or 60)
        end, false)

        addEventHandler("onDgsMouseClickUp", self.ui.checkbox["canFallOffBike"], function()
            Settings:set("canBeKnockedOffBike", dgsCheckBoxGetSelected(source))
        end, false)

        addEventHandler("onDgsMouseClickUp", self.ui.checkbox["drawBoundingBoxes"], function()
            Settings:set("drawBoundingBoxes", dgsCheckBoxGetSelected(source))
        end, false)

        dgsSetVisible(self.ui.window, false)
    end,

    buildJumpPacks = function(self)
        -- TODO: Rework to actually show jumps / jump packs and add a checkbox for every single one
        -- (Or a single checkbox that updates on the right side with an on-click / select for the grid list)
        local list = dgsCreateGridList(0, 0, 0.6, 1, true, self.ui.tab["jumps"].tab)
        dgsGridListSetSortEnabled(list, false)
        dgsGridListSetSelectionMode(list, 0)
        dgsSetProperty(list, "colorCoded", true)

        local columnActive = dgsGridListAddColumn(list, "Active", 0.1)
        local columnName = dgsGridListAddColumn(list, "Jump Pack", 0.9)

        -- Info
        local dummyLabel = dgsCreateLabel(0.61, 0.0, 0.39, 1, "", true, self.ui.tab["jumps"].tab)
        local jumpActiveCheckbox = dgsCreateCheckBox(0.0, 0.02, 0.3, 0.05, "Active", true, true, dummyLabel)

        local jumpTitle = dgsCreateLabel(0, 0.08, 0.3, 0.1, "Title: ", true, dummyLabel)
        local jumpCount = dgsCreateLabel(0, 0.12, 0.3, 0.1, "Jumps: 40", true, dummyLabel)
        local jumpCompleted = dgsCreateLabel(0, 0.16, 0.3, 0.1, "Completed: 20/40", true, dummyLabel)

        dgsSetVisible(dummyLabel, true)

        addEventHandler("onDgsGridListSelect", list, function(currentItem)
            self.ui.tab["jumps"].updateInfo()
        end, false)

        addEventHandler("onDgsMouseClickUp", jumpActiveCheckbox, function()
            local pack = self:getSelectedJumpPack()
            if not pack then
                return
            end

            local active = dgsCheckBoxGetSelected(source)
            pack:setActive(active)

            dgsGridListSetItemText(list, currentItem, columnActive, active and "X" or "")
        end, false)

        addEventHandler("onDgsGridListItemDoubleClick", list, function(button, state, itemID)
            if state ~= "down" then
                return
            end

            local pack = self:getSelectedJumpPack(itemID)
            if not pack then
                return
            end

            local active = not pack:isActive()
            pack:setActive(active)

            dgsGridListSetItemText(list, itemID, columnActive, active and "X" or "")
            dgsCheckBoxSetSelected(jumpActiveCheckbox, pack:isActive())
        end, false)

        self.ui.tab["jumps"].list = list
        self.ui.tab["jumps"].columnActive = columnActive
        self.ui.tab["jumps"].columnName = columnName

        self.ui.tab["jumps"].activeCheckbox = jumpActiveCheckbox
        self.ui.tab["jumps"].title = jumpTitle
        self.ui.tab["jumps"].count = jumpCount
        self.ui.tab["jumps"].completed = jumpCompleted

        self.ui.tab["jumps"].updateInfo = function()
            local pack = self:getSelectedJumpPack()
            if not pack then
                dgsSetVisible(dummyLabel, false)
                return
            end

            dgsSetVisible(dummyLabel, true)

            dgsCheckBoxSetSelected(jumpActiveCheckbox, pack:isActive())
            dgsSetText(jumpTitle, "Title: " .. pack.name)
            dgsSetText(jumpCount, "Jumps: " .. tostring(pack:getCount()))
            dgsSetText(jumpCompleted, "Completed: " .. tostring(Completions:getPackCompletions(pack)) .. " / " ..
                tostring(pack:getCount()))
        end

        self:updateJumpsTab()
    end,

    getSelectedJumpPackItem = function(self)
        return dgsGridListGetSelectedItem(self.ui.tab["jumps"].list)
    end,

    getSelectedJumpPack = function(self, item)
        item = (item ~= nil and item) or self:getSelectedJumpPackItem()
        if item == -1 then
            return nil
        end

        local rowText = dgsGridListGetItemText(self.ui.tab["jumps"].list, item, self.ui.tab["jumps"].columnName)
        local pack = StuntJumps:get(rowText)
        if not pack then
            return nil
        end

        return pack
    end,

    updateJumpsTab = function(self)
        dgsGridListClear(self.ui.tab["jumps"].list)

        for name, pack in pairs(StuntJumps:getAll()) do
            repeat
                if name == "editor" then
                    break
                end

                local row = dgsGridListAddRow(self.ui.tab["jumps"].list)
                dgsGridListSetItemText(self.ui.tab["jumps"].list, row, self.ui.tab["jumps"].columnActive,
                    pack:isActive() and "X" or "")
                dgsGridListSetItemText(self.ui.tab["jumps"].list, row, self.ui.tab["jumps"].columnName, name)
            until true
        end
    end,

    updateCheckboxes = function(self)
        dgsCheckBoxSetSelected(self.ui.checkbox["30FPSLimit"], Settings:get("fpsLimit") ~= 60)
        dgsCheckBoxSetSelected(self.ui.checkbox["canFallOffBike"], Settings:get("canBeKnockedOffBike"))
        dgsCheckBoxSetSelected(self.ui.checkbox["drawBoundingBoxes"], Settings:get("drawBoundingBoxes"))
    end,
}

MainUI = c_MainUI()
