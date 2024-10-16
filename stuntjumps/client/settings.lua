class "c_Settings" {
    constructor = function(self)
        self.textColor = 0xFFFFFFFF
        self.titleColor = 0xC81448AF

        addEventHandler("onClientResourceStart", resourceRoot, function()
            self:onStart()
        end)

        -- bindKey("L", "down", function()
        --     dgsSetVisible(self.window, not dgsGetVisible(self.window))
        --     showCursor(dgsGetVisible(self.window))
        -- end)
        -- showCursor(true)
    end,

    -- WIP fancy UI
    onStart = function(self)
        local width, height = guiGetScreenSize()
        local centerX, centerY = (width / 2) - (500 / 2), (height / 2) - (500 / 2)

        self.window = dgsCreateWindow(centerX, centerY, 500, 500, "Settings", false, self.textColor, 25, nil,
            self.titleColor)
        dgsWindowSetSizable(self.window, false)

        local tabPanel = dgsCreateTabPanel(0, 0, 500, 500, false, self.window)
        local tab1 = dgsCreateTab("Test", tabPanel)
        local tab2 = dgsCreateTab("Test2", tabPanel)

        local checkbox = dgsCreateCheckBox(0, 0, 100, 20, "Prevent Falling Off Bike", true, false, tab1)
        local checkbox2 = dgsCreateCheckBox(0, 20, 100, 20, "Prevent Falling Off Bike", true, false, tab1)

        local gridList = dgsCreateGridList(0, 0, 500, 500, false, tab2)
        local colid = dgsGridListAddColumn(gridList, "ID", 0.05)
        local colname = dgsGridListAddColumn(gridList, "Name", 0.5)
        for id, player in ipairs(getElementsByType("player")) do
            for i = 1, 50 do
                local row = dgsGridListAddRow(gridList)
                dgsGridListSetItemText(gridList, row, colid, tostring(i))
                dgsGridListSetItemText(gridList, row, colname, getPlayerName(player))
            end
        end

        dgsGridListSetSortEnabled(gridList, false)
        dgsSetVisible(self.window, false)
    end,
}

Settings = c_Settings()
