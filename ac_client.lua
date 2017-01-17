ACSettings = {}
AdminsListData = {}
TextsClient = {}

ACClientLoad = false

localPlayer = getLocalPlayer()
screenWidth, screenHeight = guiGetScreenSize()

addEventHandler("onClientResourceStart", getRootElement(),
    function (startedResource)
        if (startedResource == getThisResource()) then
            triggerServerEvent('ACClientResourceLoaded', getLocalPlayer())
        end
    end
)


addEvent("ACInitializeOnClient", true)

addEventHandler("ACInitializeOnClient", getRootElement(),
    function(ACSettingsLoad, AdminsListDataLoad)
        if ((ACSettingsLoad ~= nil) and (AdminsListDataLoad ~= nil)) then
            try {
                function()
                    loadACSettings(ACSettingsLoad)

                    loadAdminsListData(AdminsListDataLoad)

                    TextsClient = loadTexts("texts/data/texts_client.xml")

                    loadAdminsListGUI()

                    if (bindKey(ACSettings.OpenAdminsListButton, "down", openAdminsListWindow) == false) then
                        error({Source = "bindKey", Code = (-1)})
                    end

                    ACClientLoad = true

                    triggerServerEvent("ACInitializedOnClient", getLocalPlayer())
                end,

                catch {
                    function (LoadError)
                        ACSettings, AdminsListData = nil, nil

                        triggerServerEvent("ACErrorOutput", localPlayer, {Type = "function", Name = LoadError.Source}, LoadError.Code)
                    end
                }
            }
        else
            triggerServerEvent("ACErrorOutput", localPlayer, {Type = "event", Name = "ACInitializeOnClient"}, (-1))
        end
    end
)


addEvent("AddNewAdminsListData", true)

addEventHandler("AddNewAdminsListData", getRootElement(),
    function(adminLoginHash, NewAdminData)
        if (ACClientLoad == true) then
            if ((adminLoginHash ~= nil) and (NewAdminData ~= nil) and (AdminsListData[adminLoginHash] == nil) and (AdminsListGUIAdminsGridList.Rows[adminLoginHash] == nil)) then
                try {
                    function()
                        checkAdminData(NewAdminData)

                        local newRowID = guiGridListAddRow(AdminsListGUIAdminsGridList.Element)

                        if (newRowID == false) then
                            error({Source = "guiGridListAddRow", Code = (-1)})
                        end

                        setItemsForAdminsGridList(newRowID, NewAdminData)

                        AdminsListData[adminLoginHash] = NewAdminData

                        AdminsListGUIAdminsGridList.Rows[adminLoginHash] = newRowID
                    end,

                    catch {
                        function(EventError)
                            triggerServerEvent("ACErrorOutput", localPlayer, {Type = "function", Name = EventError.Source}, EventError.Code)
                        end
                    }
                }
            else
                triggerServerEvent("ACErrorOutput", localPlayer, {Type = "event", Name = "AddNewAdminsListData"}, (-1))
            end
        end
    end
)


addEvent("UpdateAdminsListData", true)

addEventHandler("UpdateAdminsListData", getRootElement(),
    function(adminLoginHash, UpdatedData)
        if (ACClientLoad == true) then
            if ((adminLoginHash ~= nil) and (UpdatedData ~= nil) and (AdminsListData[adminLoginHash] ~= nil) and (AdminsListGUIAdminsGridList.Rows[adminLoginHash] ~= nil)) then
                local setItemsForAdminsGridListStatus, setItemsForAdminsGridListResult = pcall(setItemsForAdminsGridList, AdminsListGUIAdminsGridList.Rows[adminLoginHash], UpdatedData)

                if (setItemsForAdminsGridListStatus == true) then
                    if (UpdatedData.Name ~= nil) then
                        AdminsListData[adminLoginHash].Name = UpdatedData.Name
                    end

                    if (UpdatedData.ACLGroup ~= nil) then
                        AdminsListData[adminLoginHash].Name = UpdatedData.ACLGroup
                    end

                    if (UpdatedData.DateOfRemoval ~= nil) then
                        AdminsListData[adminLoginHash].DateOfRemoval = UpdatedData.DateOfRemoval
                    end

                    if (UpdatedData.CurrentUse ~= nil) then
                        AdminsListData[adminLoginHash].CurrentUse = UpdatedData.CurrentUse
                    end
                else
                    AdminsListData[adminLoginHash] = LastAdminData

                    triggerServerEvent("ACErrorOutput", localPlayer, {Type = "function", Name = setItemsForAdminsGridListResult.Source}, setItemsForAdminsGridListResult.Code)
                end
            else
                triggerServerEvent("ACErrorOutput", localPlayer, {Type = "event", Name = "UpdateAdminsListData"}, (-1))
            end
        end
    end
)


addEvent("DeleteAdminsListData", true)

addEventHandler("DeleteAdminsListData", getRootElement(),
    function(adminLoginHash)
        if (ACClientLoad == true) then
            if ((AdminsListData[adminLoginHash] ~= nil) and (AdminsListGUIAdminsGridList.Rows[adminLoginHash] ~= nil)) then
                if (guiGridListRemoveRow(AdminsListGUIAdminsGridList.Element, AdminsListGUIAdminsGridList.Rows[adminLoginHash]) == true) then
                    AdminsListData[adminLoginHash] = nil
                    AdminsListGUIAdminsGridList.Rows[adminLoginHash] = nil
                else
                    triggerServerEvent("ACErrorOutput", localPlayer, {Type = "event", Name = "DeleteAdminsListData"}, (-1))
                end
            else
                triggerServerEvent("ACErrorOutput", localPlayer, {Type = "event", Name = "DeleteAdminsListData"}, (-1))
            end
        end
    end
)


addEvent("WarningAboutDeadlineOfAdmin", true)

addEventHandler("WarningAboutDeadlineOfAdmin", getRootElement(),
    function()
        if (ACClientLoad == true) then
            try {
                function()
                    loadWarningAboutDeadlineOfAdminGUI()
                end,

                catch {
                    function(EventError)
                        triggerServerEvent("ACErrorOutput", localPlayer, {Type = "function", Name = EventError.Source}, EventError.Code)
                    end
                }
            }
        end
    end
)


addEventHandler("onClientResourceStop", getRootElement(),
    function(stoppedResource)
        if (startedResource == getThisResource()) then
            if (ACClientLoad == 1) then
                unbindKey(ACSettings.OpenAdminsListButton)
            end
        end
    end
)


function openAdminsListWindow(key, keyState)
    if ((key == ACSettings.OpenAdminsListButton) and (keyState == "down")) then
        if (guiGetVisible(AdminsListGUIWindow.Element) == true) then
            guiSetVisible(AdminsListGUIWindow.Element, false)
            showCursor(false)
        else
            guiSetVisible(AdminsListGUIWindow.Element, true)
            showCursor(true)
        end
    end
end


function loadAdminsListGUI()
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    --Create window
    AdminsListGUIWindow = {}

    AdminsListGUIWindow.Width = 830 * ACSettings.GUIScale
    AdminsListGUIWindow.Height = 600 * ACSettings.GUIScale

    AdminsListGUIWindow.X = ((screenWidth - AdminsListGUIWindow.Width) / 2)
    AdminsListGUIWindow.Y = ((screenHeight - AdminsListGUIWindow.Height) / 2)

    AdminsListGUIWindow.Element = guiCreateWindow(
        AdminsListGUIWindow.X,
        AdminsListGUIWindow.Y,
        AdminsListGUIWindow.Width,
        AdminsListGUIWindow.Height,
        TextsClient.AdminsListGUI.WindowTitle,
        false)

    if (AdminsListGUIWindow.Element == false) then
        ErrorData.Code = (-1)

        error(ErrorData)
    end

    guiWindowSetSizable(AdminsListGUIWindow.Element, false)
    guiSetVisible(AdminsListGUIWindow.Element, false)

    --Create list of admins
    AdminsListGUIAdminsGridList = {}

    AdminsListGUIAdminsGridList.Width = AdminsListGUIWindow.Width - 20 * ACSettings.GUIScale
    AdminsListGUIAdminsGridList.Height = 480 * ACSettings.GUIScale

    AdminsListGUIAdminsGridList.X = 10 * ACSettings.GUIScale
    AdminsListGUIAdminsGridList.Y = 45 * ACSettings.GUIScale

    local currentHeightPosition = AdminsListGUIAdminsGridList.Y + AdminsListGUIAdminsGridList.Height

    AdminsListGUIAdminsGridList.Element = guiCreateGridList(
        AdminsListGUIAdminsGridList.X,
        AdminsListGUIAdminsGridList.Y,
        AdminsListGUIAdminsGridList.Width,
        AdminsListGUIAdminsGridList.Height,
        false,
        AdminsListGUIWindow.Element)

    if (AdminsListGUIAdminsGridList.Element == false) then
        ErrorData.Code = (-2)

        error(ErrorData)
    end

    --Create columns
    AdminsListGUIAdminsGridList.Columns = {}

    AdminsListGUIAdminsGridList.Columns.Name = guiGridListAddColumn(AdminsListGUIAdminsGridList.Element, TextsClient.AdminsListGUI.GridList.Columns.NameTitle, 0.28)

    if (AdminsListGUIAdminsGridList.Columns.Name == false) then
        ErrorData.Code = (-3)

        error(ErrorData)
    end

    AdminsListGUIAdminsGridList.Columns.ACLGroup = guiGridListAddColumn(AdminsListGUIAdminsGridList.Element, TextsClient.AdminsListGUI.GridList.Columns.ACLGroupTitle, 0.27)

    if (AdminsListGUIAdminsGridList.Columns.ACLGroup == false) then
        ErrorData.Code = (-4)

        error(ErrorData)
    end

    AdminsListGUIAdminsGridList.Columns.DateOfRemoval = guiGridListAddColumn(AdminsListGUIAdminsGridList.Element, TextsClient.AdminsListGUI.GridList.Columns.DateOfRemovalTitle, 0.24)

    if (AdminsListGUIAdminsGridList.Columns.DateOfRemoval == false) then
        ErrorData.Code = (-5)

        error(ErrorData)
    end

    AdminsListGUIAdminsGridList.Columns.CurrentUse = guiGridListAddColumn(AdminsListGUIAdminsGridList.Element, TextsClient.AdminsListGUI.GridList.Columns.CurrentUseTitle, 0.15)

    if (AdminsListGUIAdminsGridList.Columns.CurrentUse == false) then
        ErrorData.Code = (-6)

        error(ErrorData)
    end

    --Create rows
    AdminsListGUIAdminsGridList.Rows = {}

    for aldKey, aldValue in pairs(AdminsListData) do
        local rowID = guiGridListAddRow(AdminsListGUIAdminsGridList.Element)

        if (rowID == false) then
            ErrorData.Key = aldKey

            ErrorData.Code = (-7)

            error(ErrorData)
        end

        AdminsListGUIAdminsGridList.Rows[aldKey] = rowID

        local setItemsForAdminsGridListStatus, setItemsForAdminsGridListResult = pcall(setItemsForAdminsGridList, rowID, aldValue)

        if (setItemsForAdminsGridListStatus == false) then
            ErrorData.Key = setItemsForAdminsGridListResult

            ErrorData.Code = (-8)

            error(ErrorData)
        end
    end

    --Create show/hide info label
    AdminsListGUIShowHideInfoLabel = {}

    AdminsListGUIShowHideInfoLabel.Width = AdminsListGUIWindow.Width - 20 * ACSettings.GUIScale
    AdminsListGUIShowHideInfoLabel.Height = 25 * ACSettings.GUIScale

    AdminsListGUIShowHideInfoLabel.X = 10 * ACSettings.GUIScale
    AdminsListGUIShowHideInfoLabel.Y = currentHeightPosition + 20 * ACSettings.GUIScale

    AdminsListGUIShowHideInfoLabel.Element = guiCreateLabel(
        AdminsListGUIShowHideInfoLabel.X,
        AdminsListGUIShowHideInfoLabel.Y,
        AdminsListGUIShowHideInfoLabel.Width,
        AdminsListGUIShowHideInfoLabel.Height,
        string.gsub(TextsClient.AdminsListGUI.ShowHideInfoLabelText, "$open_admins_list_button", ACSettings.OpenAdminsListButton),
        false,
        AdminsListGUIWindow.Element)

    if (AdminsListGUIShowHideInfoLabel.Element == false) then
        ErrorData.Code = (-9)

        error(ErrorData)
    end

    guiLabelSetHorizontalAlign(AdminsListGUIShowHideInfoLabel.Element, "center")
    guiLabelSetVerticalAlign(AdminsListGUIShowHideInfoLabel.Element, "center")
end


function loadWarningAboutDeadlineOfAdminGUI ()
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    --Create window
    WarningAboutDeadlineOfAdminGUIWindow = {}

    WarningAboutDeadlineOfAdminGUIWindow.Width = 600 * ACSettings.GUIScale
    WarningAboutDeadlineOfAdminGUIWindow.Height = 250 * ACSettings.GUIScale

    WarningAboutDeadlineOfAdminGUIWindow.X = ((screenWidth - WarningAboutDeadlineOfAdminGUIWindow.Width) / 2)
    WarningAboutDeadlineOfAdminGUIWindow.Y = ((screenHeight - WarningAboutDeadlineOfAdminGUIWindow.Height) / 2)

    WarningAboutDeadlineOfAdminGUIWindow.Element = guiCreateWindow(
        WarningAboutDeadlineOfAdminGUIWindow.X,
        WarningAboutDeadlineOfAdminGUIWindow.Y,
        WarningAboutDeadlineOfAdminGUIWindow.Width,
        WarningAboutDeadlineOfAdminGUIWindow.Height,
        TextsClient.WarningAboutDeadlineOfAdminGUI.WindowTitle,
        false)

    if (WarningAboutDeadlineOfAdminGUIWindow.Element == false) then
        ErrorData.Code = (-1)

        error(ErrorData)
    end

    guiWindowSetSizable(WarningAboutDeadlineOfAdminGUIWindow.Element, false)

    --Create text label
    WarningAboutDeadlineOfAdminGUITextLabel = {}

    WarningAboutDeadlineOfAdminGUITextLabel.Width = WarningAboutDeadlineOfAdminGUIWindow.Width - 20 * ACSettings.GUIScale
    WarningAboutDeadlineOfAdminGUITextLabel.Height = 130 * ACSettings.GUIScale

    WarningAboutDeadlineOfAdminGUITextLabel.X = 10 * ACSettings.GUIScale
    WarningAboutDeadlineOfAdminGUITextLabel.Y = 50 * ACSettings.GUIScale

    local currentHeightPosition = WarningAboutDeadlineOfAdminGUITextLabel.Y + WarningAboutDeadlineOfAdminGUITextLabel.Height

    WarningAboutDeadlineOfAdminGUITextLabel.Element = guiCreateLabel(
        WarningAboutDeadlineOfAdminGUITextLabel.X,
        WarningAboutDeadlineOfAdminGUITextLabel.Y,
        WarningAboutDeadlineOfAdminGUITextLabel.Width,
        WarningAboutDeadlineOfAdminGUITextLabel.Height,
        string.gsub(TextsClient.WarningAboutDeadlineOfAdminGUI.WarningText, "#br#", "\n\n"),
        false,
        WarningAboutDeadlineOfAdminGUIWindow.Element)

    if (WarningAboutDeadlineOfAdminGUITextLabel.Element == false) then
        ErrorData.Code = (-2)

        error(ErrorData)
    end

    --Confirm button
    WarningAboutDeadlineOfAdminGUIConfirmButton = {}

    WarningAboutDeadlineOfAdminGUIConfirmButton.Width = 100 * ACSettings.GUIScale
    WarningAboutDeadlineOfAdminGUIConfirmButton.Height = 100 * ACSettings.GUIScale

    WarningAboutDeadlineOfAdminGUIConfirmButton.X = (WarningAboutDeadlineOfAdminGUIWindow.Width - WarningAboutDeadlineOfAdminGUIConfirmButton.Width) / 2
    WarningAboutDeadlineOfAdminGUIConfirmButton.Y = currentHeightPosition + 20 * ACSettings.GUIScale

    WarningAboutDeadlineOfAdminGUIConfirmButton.Element = guiCreateButton(
        WarningAboutDeadlineOfAdminGUIConfirmButton.X,
        WarningAboutDeadlineOfAdminGUIConfirmButton.Y,
        WarningAboutDeadlineOfAdminGUIConfirmButton.Width,
        WarningAboutDeadlineOfAdminGUIConfirmButton.Height,
        TextsClient.WarningAboutDeadlineOfAdminGUI.ConfirmButtonText,
        false,
        WarningAboutDeadlineOfAdminGUIWindow.Element
    )

    if (WarningAboutDeadlineOfAdminGUIConfirmButton.Element == false) then
        ErrorData.Code = (-3)

        error(ErrorData)
    end

    addEventHandler("onClientGUIClick", WarningAboutDeadlineOfAdminGUIConfirmButton.Element,
        function(button, state)
            if ((button == "left") and (state == "up") and (source == WarningAboutDeadlineOfAdminGUIConfirmButton.Element)) then
                guiSetVisible(WarningAboutDeadlineOfAdminGUIWindow.Element, false)
                showCursor(false)
            end
        end
    )

    showCursor(true)
end


function setItemsForAdminsGridList(rowIndex, ItemsData)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    if (ItemsData.Name ~= nil) then
        local nameText = string.gsub(ItemsData.Name, '#%x%x%x%x%x%x', '')

        if (nameText == "") then
            nameText = ItemsData.Name
        end

        if (guiGridListSetItemText(AdminsListGUIAdminsGridList.Element, rowIndex, AdminsListGUIAdminsGridList.Columns.Name,  nameText, false, false) == false) then
            ErrorData.Code = (-1)

            error(ErrorData)
        end
    end

    if (ItemsData.ACLGroup ~= nil) then
        local aclGroupText = ItemsData.ACLGroup

        if ((TextsClient.AdminsListGUI.GridList.ACLGroup ~= nil) and (TextsClient.AdminsListGUI.GridList.ACLGroup[ItemsData.ACLGroup] ~= nil)) then
            aclGroupText = TextsClient.AdminsListGUI.GridList.ACLGroup[ItemsData.ACLGroup]
        end

        if (guiGridListSetItemText(AdminsListGUIAdminsGridList.Element, rowIndex, AdminsListGUIAdminsGridList.Columns.ACLGroup, aclGroupText, false, false) == false) then
            ErrorData.Code = (-2)

            error(ErrorData)
        end
    end

    if (ItemsData.DateOfRemoval ~= nil) then
        local dateOfRemovalTime = getRealTime(ItemsData.DateOfRemoval)

        local dateOfRemovalFormatted = string.format("%02d/%02d/%04d", dateOfRemovalTime.monthday, dateOfRemovalTime.month + 1, dateOfRemovalTime.year + 1900)

        if (guiGridListSetItemText(AdminsListGUIAdminsGridList.Element, rowIndex, AdminsListGUIAdminsGridList.Columns.DateOfRemoval, dateOfRemovalFormatted, false, false) == false) then
            ErrorData.Code = (-3)

            error(ErrorData)
        end
    end

    if (ItemsData.CurrentUse ~= nil) then
        local currentUseText = TextsClient.AdminsListGUI.GridList.CurrentUse.OfflineText

        local currentUseTextColor = {R = 255, G = 0, B = 0}

        if (ItemsData.CurrentUse == true) then
            currentUseText = TextsClient.AdminsListGUI.GridList.CurrentUse.OnlineText

            currentUseTextColor = {R = 0, G = 255, B = 0}
        end

        if (guiGridListSetItemText(AdminsListGUIAdminsGridList.Element, rowIndex, AdminsListGUIAdminsGridList.Columns.CurrentUse, currentUseText, false, false) == false) then
            ErrorData.Code = (-4)

            error(ErrorData)
        end

        guiGridListSetItemColor(AdminsListGUIAdminsGridList.Element, rowIndex, AdminsListGUIAdminsGridList.Columns.CurrentUse, currentUseTextColor.R, currentUseTextColor.G, currentUseTextColor.B)
    end
end


function loadAdminsListData(AdminsListDataLoad)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    for aldlKey, aldlValue in pairs(AdminsListDataLoad) do
        local checkAdminDataStatus, checkAdminDataResult = pcall(checkAdminData, aldlValue)

        if (checkAdminDataStatus == true) then
            AdminsListData[aldlKey] = aldlValue
        else
            ErrorData.Key = aldlKey

            ErrorData.Code = checkAdminDataResult.Code

            error(ErrorData)
        end
    end
end


function checkAdminData(AdminData)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    if (AdminData.Name == nil) then
        ErrorData.Code = (-1)
    elseif (AdminData.ACLGroup == nil) then
        ErrorData.Code = (-2)
    elseif (AdminData.DateOfRemoval == nil) then
        ErrorData.Code = (-3)
    elseif (AdminData.CurrentUse == nil) then
        ErrorData.Code = (-4)
    end

    if (ErrorData.Code ~= 0) then
        error(ErrorData)
    end
end


function loadACSettings(ACSettingsLoad)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    if (ACSettingsLoad.OpenAdminsListButton == nil) then
        ErrorData.Code = (-1)
    elseif (ACSettingsLoad.GUIScale == nil) then
        ErrorData.Code = (-2)
    end

    if (ErrorData.Code == 0) then
        ACSettings = ACSettingsLoad

        ACSettings.GUIScale = (ACSettings.GUIScale * screenWidth) / 10000

        if (ACSettings.GUIScale > 1) then
            ACSettings.GUIScale = 1
        end
    else
        error(ErrorData)
    end
end