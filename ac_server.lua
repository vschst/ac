ACSettings = {}
AdminsData = {}
TextsServer = {}

ACServerLoad = false

ACLoadedPlayers = {}


addEventHandler("onResourceStart", getRootElement(),
    function(startedResource)
        if (startedResource == getThisResource()) then
            try {
                function()
                    loadACSettings()

                    loadAdminsData()

                    TextsServer = loadTexts("texts/data/texts_server.xml")

                    AdminsDataCleanTimer = setTimer(adminsDataClean, ACSettings.AdminsDataCleanPeriod * 60 * 1000, 1)

                    if (AdminsDataCleanTimer == false) then
                        error({Source = "setTimer", Code = (-1)})
                    end

                    ACServerLoad = true

                    outputServerLog("[AC] Resource was successfully loaded!")
                end,

                catch {
                    function(LoadError)
                        ACSettings, AdminsData = nil, nil

                        outputServerLog("[AC] Load error! Error in function: " .. LoadError.Source .. ", Error code: " .. LoadError.Code)
                    end
                }
            }
        end
    end
)


addEvent("ACErrorOutput", true)

addEventHandler("ACErrorOutput", getRootElement(),
    function(ErrorSource, ErrorCode)
        if (getElementType(source) == "player") then
            outputServerLog("[AC] Error! Player: " .. getPlayerName(source) .. ", Error in " .. ErrorSource.Type .. " (Name: '" .. ErrorSource.Name .. "', ErrorCode: '" .. ErrorCode .. "')")
        else
            outputServerLog("[GM] Error! Error in " .. ErrorSource.Type .. " (Name: '" .. ErrorSource.Name .. "', ErrorCode: '" .. ErrorCode .. "')")
        end
    end
)


addEvent("ACClientResourceLoaded", true)

addEventHandler("ACClientResourceLoaded", getRootElement(),
    function()
        if (ACServerLoad == true) then
            ACLoadedPlayers[source] = 1

            local ACSettingsClient = {
                OpenAdminsListButton = ACSettings.ClientOpenAdminsListButton,

                GUIScale = ACSettings.ClientGUIScale
            }

            local AdminsListClient = {}

            for adKey, adValue in pairs(AdminsData) do
                if (adValue.Name ~= nil) then
                    AdminsListClient[md5(adKey)] = {
                        ACLGroup = adValue.ACLGroup,

                        DateOfRemoval = (adValue.DateOfIssue + (adValue.Term * 86400)),

                        Name = adValue.Name,

                        CurrentUse = adValue.CurrentUse
                    }
                end
            end

            triggerClientEvent(source, "ACInitializeOnClient", source, ACSettingsClient, AdminsListClient)
        end
    end
)


addEvent("ACInitializedOnClient", true)

addEventHandler("ACInitializedOnClient", getRootElement(),
    function()
        ACLoadedPlayers[source] = 2
    end
)


addEventHandler("onPlayerJoin", getRootElement(),
    function()
        if (ACServerLoad == true) then
            local playerIP = getPlayerIP(source)

            local playerSerial = getPlayerSerial(source)

            local playerName = getPlayerName(source)

            if ((playerIP ~= false) and (playerSerial ~= false) and (playerName ~= false)) then
                for adKey, adValue in pairs(AdminsData) do
                    if (((adValue.IP ~= nil) and (adValue.IP == playerIP)) or ((adValue.Serial ~= nil) and (adValue.Serial == playerSerial))) then
                        playerName = string.gsub(playerName, '#%x%x%x%x%x%x', '')

                        outputChatBox(string.gsub(TextsServer.AdminJoinToServer, "$player_name", playerName), getRootElement(), 255, 51, 51)

                        break
                    end
                end
            end
        end
    end
)


addEventHandler("onPlayerQuit", getRootElement(),
    function()
        if (ACServerLoad == true) then
            if (ACLoadedPlayers[source] ~= nil) then
                ACLoadedPlayers[source] = nil
            end

            local playerAccount = getPlayerAccount(source)

            if (playerAccount ~= false) then
                if (isGuestAccount(playerAccount) == false) then
                    local playerLogin = getAccountName(playerAccount)

                    if (playerLogin ~= false) then
                        if ((AdminsData[playerLogin] ~= nil) and (AdminsData[playerLogin].Name ~= nil)) then
                            AdminsData[playerLogin].CurrentUse = true

                            for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                                if (aclpValue == 2) then
                                    triggerClientEvent(aclpKey, "UpdateAdminsListData", aclpKey, md5(playerLogin), {CurrentUse = false})
                                end
                            end
                        end
                    else
                        triggerEvent("ACErrorOutput", source, {Type = "event", Name = "onPlayerQuit"}, (-2))
                    end
                end
            else
                triggerEvent("ACErrorOutput", source, {Type = "event", Name = "onPlayerQuit"}, (-1))
            end
        end
    end
)


addEventHandler("onPlayerLogin", getRootElement(),
    function (thePreviousAccount, theCurrentAccount)
        if (ACServerLoad == true) then
            local playerLogin = getAccountName(theCurrentAccount)

            local playerIP = getPlayerIP(source)

            local playerSerial = getPlayerSerial(source)

            local playerName = getPlayerName(source)

            if ((playerLogin ~= false) and (playerIP ~= false) and (playerSerial ~= false) and (playerName ~= false)) then
                if (AdminsData[playerLogin] ~= nil) then
                    if ((AdminsData[playerLogin].BindingToSerial == true) and (AdminsData[playerLogin].Serial ~= nil) and (AdminsData[playerLogin].Serial ~= playerSerial)) then
                        kickPlayer(source, TextsServer.LoginOfAnotherAdminAccount)
                    else
                        local addNewAdminsListDataOnClient = false

                        if (AdminsData[playerLogin].Name == nil) then
                            addNewAdminsListDataOnClient = true
                        end

                        local updateAdminDataStatus, updateAdminDataResult = pcall(updateAdminData, playerLogin, {IP = playerIP, Serial = playerSerial, Name = playerName})

                        if (updateAdminDataStatus == true) then
                            AdminsData[playerLogin].CurrentUse = true

                            if (addNewAdminsListDataOnClient == true) then
                                local NewAdminsListDataClient = {
                                    Name = AdminsData[playerLogin].Name,

                                    ACLGroup = AdminsData[playerLogin].ACLGroup,

                                    DateOfRemoval = (AdminsData[playerLogin].DateOfIssue + (AdminsData[playerLogin].Term * 86400)),

                                    CurrentUse = AdminsData[playerLogin].CurrentUse
                                }

                                for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                                    if (aclpValue == 2) then
                                        triggerClientEvent(aclpKey, "AddNewAdminsListData", aclpKey, md5(playerLogin), NewAdminsListDataClient)
                                    end
                                end
                            else
                                for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                                    if (aclpValue == 2) then
                                        triggerClientEvent(aclpKey, "UpdateAdminsListData", aclpKey, md5(playerLogin), {Name = AdminsData[playerLogin].Name, CurrentUse = AdminsData[playerLogin].CurrentUse})
                                    end
                                end
                            end

                            local adminDateOfRemoval = (AdminsData[playerLogin].DateOfIssue + (AdminsData[playerLogin].Term * 86400))

                            local realTime = getRealTime()

                            if ((adminDateOfRemoval - realTime.timestamp) < 43200) then
                                triggerClientEvent(source, "WarningAboutDeadlineOfAdmin", source)
                            end
                        else
                            triggerEvent("ACErrorOutput", source, {Type = "function", Name = updateAdminDataResult.Source}, updateAdminDataResult.Code)
                        end
                    end
                end
            else
                triggerEvent("ACErrorOutput", source, {Type = "event", Name = "onPlayerLogin"}, (-1))
            end
        end
    end
)


addEventHandler("onPlayerLogout", getRootElement(),
    function (thePreviousAccount)
        if (ACServerLoad == true) then
            local playerLogin = getAccountName(thePreviousAccount)

            if (playerLogin ~= false) then
                if (AdminsData[playerLogin] ~= nil) then
                    AdminsData[playerLogin].CurrentUse = false

                    if (AdminsData[playerLogin].Name ~= nil) then
                        for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                            if (aclpValue == 2) then
                                triggerClientEvent(aclpKey, "UpdateAdminsListData", aclpKey, md5(playerLogin), {CurrentUse = false})
                            end
                        end
                    end
                end
            else
                triggerEvent("ACErrorOutput", source, {Type = "event", Name = "onPlayerLogout"}, (-1))
            end
        end
    end
)


addEventHandler("onPlayerChangeNick", getRootElement(),
    function (oldNick, newNick)
        if (ACServerLoad == true) then
            local playerAccount = getPlayerAccount(source)

            if (playerAccount ~= false) then
                if (isGuestAccount(playerAccount) == false) then
                    local playerLogin = getAccountName(playerAccount)

                    if (playerLogin ~= false) then
                        if (AdminsData[playerLogin] ~= nil) then
                            local addNewAdminsListDataOnClient = false

                            if (AdminsData[playerLogin].Name == nil) then
                                addNewAdminsListDataOnClient = true
                            end

                            local updateAdminDataStatus, updateAdminDataResult = pcall(updateAdminData, playerLogin, {Name = newNick})

                            if (updateAdminDataStatus == true) then
                                if (addNewAdminsListDataOnClient == true) then
                                    AdminsData[playerLogin].CurrentUse = true

                                    local NewAdminsListDataClient = {
                                        Name = AdminsData[playerLogin].Name,

                                        ACLGroup = AdminsData[playerLogin].ACLGroup,

                                        DateOfRemoval = (AdminsData[playerLogin].DateOfIssue + (AdminsData[playerLogin].Term * 86400)),

                                        CurrentUse = AdminsData[playerLogin].CurrentUse
                                    }

                                    for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                                        if (aclpValue == 2) then
                                            triggerClientEvent(aclpKey, "AddNewAdminsListData", aclpKey, md5(playerLogin), NewAdminsListDataClient)
                                        end
                                    end
                                else
                                    for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                                        if (aclpValue == 2) then
                                            triggerClientEvent(aclpKey, "UpdateAdminsListData", aclpKey, md5(playerLogin), {Name = AdminsData[playerLogin].Name})
                                        end
                                    end
                                end
                            else
                                triggerEvent("ACErrorOutput", source, {Type = "function", Name = updateAdminDataResult.Source}, updateAdminDataResult.Code)
                            end
                        end
                    else
                        triggerEvent("ACErrorOutput", source, {Type = "event", Name = "onPlayerChangeNick"}, (-2))
                    end
                end
            else
                triggerEvent("ACErrorOutput", source, {Type = "event", Name = "onPlayerChangeNick"}, (-1))
            end
        end
    end
)


addEventHandler ("onResourceStop", getRootElement(),
    function (theResourceStopped)
        if (theResourceStopped == getThisResource()) then
            if (ACServerLoad == true) then
                killTimer(AdminsDataCleanTimer)

                AdminsDataCleanTimer = nil
            end
        end
    end
)


function adminsDataClean()
    local AdminsDataXMLFile = xmlLoadFile("data/admins_data.xml")

    if (AdminsDataXMLFile ~= false) then
        local AdminsDataXMLFile_Admins = xmlNodeGetChildren(AdminsDataXMLFile)

        if (AdminsDataXMLFile_Admins ~= false) then
            if (#AdminsDataXMLFile_Admins > 0) then
                local realTime = getRealTime()

                local RemovedAdminsData = {Quantity = 0, FailedQuantity = 0, Logs = {}}

                for aKey, aValue in ipairs(AdminsDataXMLFile_Admins) do
                    local adminACLGroup = xmlNodeGetAttribute(aValue, "ACLGroup")

                    local adminDateOfIssue = xmlNodeGetAttribute(aValue, "DateOfIssue")

                    local adminTerm = xmlNodeGetAttribute(aValue, "Term")

                    local adminName = xmlNodeGetAttribute(aValue, "Name")

                    local adminLogin = xmlNodeGetValue(aValue)

                    if ((adminACLGroup ~= false) and (adminDateOfIssue ~= false) and (adminTerm ~= false) and (adminLogin ~= false)) then
                        local adminTimeOfRemoval = (tonumber(adminDateOfIssue) + (tonumber(adminTerm) * 86400))

                        if (realTime.timestamp > adminTimeOfRemoval) then
                            aclGroupRemoveObject (aclGetGroup(adminACLGroup), "user."..adminLogin)

                            if (xmlDestroyNode(aValue) == true) then
                                AdminsData[adminLogin] = nil

                                RemovedAdminsData.Quantity = RemovedAdminsData.Quantity + 1

                                table.insert(RemovedAdminsData.Logs, "[AC] REMOVED ADMIN. Admin login : " .. adminLogin)

                                if (adminName ~= false) then
                                    for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                                        if (aclpValue == 2) then
                                            triggerClientEvent(aclpKey, "DeleteAdminsListData", aclpKey, md5(adminLogin))
                                        end
                                    end
                                end
                            else
                                RemovedAdminsData.FailedQuantity = RemovedAdminsData.FailedQuantity + 1

                                triggerEvent("ACErrorOutput", root,  {Type = "event", Name = "adminsDataClean", AdminLogin = adminLogin}, (-4))
                            end
                        end
                    else
                        triggerEvent("ACErrorOutput", root,  {Type = "event", Name = "adminsDataClean", Key = aKey}, (-3))
                    end
                end

                if (xmlSaveFile(AdminsDataXMLFile) == true) then
                    if ((RemovedAdminsData.Quantity) > 0 or (RemovedAdminsData.FailedQuantity > 0)) then
                        outputServerLog("[AC] Removed admins data: " .. RemovedAdminsData.Quantity .. ", failed removed: " .. RemovedAdminsData.FailedQuantity)
                    end

                    fileCopy("data/admins_data.xml", "backups/admins_data.xml", true)

                    if (#RemovedAdminsData.Logs > 0) then
                        addDataToAdminsLog(RemovedAdminsData.Logs)
                    end
                else
                    triggerEvent("ACErrorOutput", root, {Type = "event", Name = "adminsDataClean"}, (-5))
                end
            end
        else
            triggerEvent("ACErrorOutput", root, {Type = "event", Name = "adminsDataClean"}, (-2))
        end
    else
        triggerEvent("ACErrorOutput", root, {Type = "event", Name = "adminsDataClean"}, (-1))
    end

    xmlUnloadFile(AdminsDataXMLFile)

    AdminsDataCleanTimer = setTimer(adminsDataClean, ACSettings.AdminsDataCleanPeriod * 60 * 1000, 1)
end


function addDataToAdminsLog(theData)
    local adminsLogFile = fileOpen("logs/admins.log")

    if (adminsLogFile ~= false) then
        local realTime = getRealTime()

        local realTimeFormatted = string.format("%04d/%02d/%02d %02d:%02d:%02d", (realTime.year +  1900), (realTime.month + 1), realTime.monthday, realTime.hour, realTime.minute, realTime.second)

        local writesString = ""

        if (type(theData) == "table") then
            for tdKey, tdValue in ipairs(theData) do
                writesString = "[" .. realTimeFormatted .. "] " .. tdValue .. "\n"
            end
        elseif (type(theData) == "string") then
            writesString = "[" .. realTimeFormatted .. "] " .. theData .. "\n"
        end

        fileSetPos(adminsLogFile, fileGetSize(adminsLogFile))
        fileWrite(adminsLogFile, writesString)
        fileClose(adminsLogFile)

        fileCopy("logs/admins.log", "backups/admins.log", true)
    else
        outputServerLog("[AC] Unable to open log file admins.log")
    end
end


function getAdminDataXMLNode(AdminsDataXMLFile, adminLogin)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    local AdminsDataXMLFile_Admins = xmlNodeGetChildren(AdminsDataXMLFile)

    if (AdminsDataXMLFile_Admins == false) then
        ErrorData.Code = (-1)
        error(ErrorData)
    end

    ErrorData.Code = (-2)

    for aKey, aValue in ipairs(AdminsDataXMLFile_Admins) do
        if (xmlNodeGetValue(aValue) == adminLogin) then
            return aValue
        end
    end

    error(ErrorData)
end


function addNewAdminData(newAdminLogin, NewAdminData)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    local AdminsDataXMLFile = xmlLoadFile("data/admins_data.xml")

    if (AdminsDataXMLFile == false) then
        ErrorData.Code = (-1)
        error(ErrorData)
    end

    local bindingToSerialXML = "0"

    if (NewAdminData.BindingToSerial == true) then
        bindingToSerialXML = "1"
    end

    local AdminsDataXMLFile_NewAdminDataXMLNode = xmlCreateChild(AdminsDataXMLFile, "Admin")

    if (AdminsDataXMLFile_NewAdminDataXMLNode == false) then
        ErrorData.Code = (-2)
    elseif (xmlNodeSetAttribute(AdminsDataXMLFile_NewAdminDataXMLNode, "ACLGroup", NewAdminData.ACLGroup) == false) then
        ErrorData.Code = (-3)
    elseif (xmlNodeSetAttribute(AdminsDataXMLFile_NewAdminDataXMLNode, "Issued", NewAdminData.Issued) == false) then
        ErrorData.Code = (-4)
    elseif (xmlNodeSetAttribute(AdminsDataXMLFile_NewAdminDataXMLNode, "DateOfIssue", tostring(NewAdminData.DateOfIssue)) == false) then
        ErrorData.Code = (-5)
    elseif (xmlNodeSetAttribute(AdminsDataXMLFile_NewAdminDataXMLNode, "Term", tostring(NewAdminData.Term)) == false) then
        ErrorData.Code = (-6)
    elseif (xmlNodeSetAttribute(AdminsDataXMLFile_NewAdminDataXMLNode, "BindingToSerial", bindingToSerialXML) == false) then
        ErrorData.Code = (-7)
    elseif (xmlNodeSetValue(AdminsDataXMLFile_NewAdminDataXMLNode, newAdminLogin) == false) then
        ErrorData.Code = (-8)
    elseif (xmlSaveFile(AdminsDataXMLFile) == false) then
        ErrorData.Code = (-9)
    else
        AdminsData[newAdminLogin] = NewAdminData

        addDataToAdminsLog("[AC] ADD NEW ADMIN. Login : " .. newAdminLogin .. ", Issued: " .. NewAdminData.Issued .. ", ACL Group: " .. NewAdminData.ACLGroup .. ", Term: " .. NewAdminData.Term)

        fileCopy("data/admins_data.xml", "backups/admins_data.xml", true)
    end

    xmlUnloadFile(AdminsDataXMLFile)

    if (ErrorData.Code ~= 0) then
        error(ErrorData)
    end
end


function removeAdminData(adminLogin)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    local AdminsDataXMLFile = xmlLoadFile("data/admins_data.xml")

    if (AdminsDataXMLFile == false) then
        ErrorData.Code = (-1)
        error(ErrorData)
    end

    local getAdminDataXMLNodeStatus, getAdminDataXMLNodeResult = pcall(getAdminDataXMLNode, AdminsDataXMLFile, adminLogin)

    if (getAdminDataXMLNodeStatus == false) then
        ErrorData.Code = (-2)
    elseif (xmlDestroyNode(getAdminDataXMLNodeResult) == false) then
        ErrorData.Code = (-3)
    elseif (xmlSaveFile(AdminsDataXMLFile) == false) then
        ErrorData.Code = (-4)
    else
        AdminsData[adminLogin] = nil

        addDataToAdminsLog("REMOVE ADMIN. Admin login : " .. adminLogin)

        fileCopy("data/admins_data.xml", "backups/admins_data.xml", true)
    end

    xmlUnloadFile(AdminsDataXMLFile)

    if (ErrorData.Code ~= 0) then
        error(ErrorData)
    end
end


function updateAdminData(adminLogin, UpdatedData)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0 }

    local AdminsDataXMLFile = xmlLoadFile("data/admins_data.xml")

    if (AdminsDataXMLFile == false) then
        ErrorData.Code = (-1)
        error(ErrorData)
    end

    local getAdminDataXMLNodeStatus, getAdminDataXMLNodeResult = pcall(getAdminDataXMLNode, AdminsDataXMLFile, adminLogin)

    if (getAdminDataXMLNodeStatus == true) then
        local LastAdminData = AdminsData[adminLogin]

        local UpdateLogs = {}

        if (UpdatedData.ACLGroup ~= nil) then
            if (xmlNodeSetAttribute(getAdminDataXMLNodeResult, "ACLGroup", UpdatedData.ACLGroup) == false) then
                ErrorData.Code = (-3)
            else
                AdminsData[adminLogin].ACLGroup = UpdatedData.ACLGroup

                table.insert(UpdateLogs, "ACL group: " .. UpdatedData.ACLGroup)
            end
        end

        if ((ErrorData.Code == 0) and (UpdatedData.Term ~= nil)) then
            if (xmlNodeSetAttribute(getAdminDataXMLNodeResult, "Term", tostring(UpdatedData.Term)) == false) then
                ErrorData.Code = (-4)
            else
                AdminsData[adminLogin].Term = UpdatedData.Term

                table.insert(UpdateLogs, "Term: " .. UpdatedData.Term)
            end
        end

        if ((ErrorData.Code == 0) and (UpdatedData.IP ~= nil)) then
            if (xmlNodeSetAttribute(getAdminDataXMLNodeResult, "IP", UpdatedData.IP) == false) then
                ErrorData.Code = (-5)
            else
                AdminsData[adminLogin].IP = UpdatedData.IP
            end
        end

        if ((ErrorData.Code == 0) and (UpdatedData.Serial ~= nil)) then
            if (xmlNodeSetAttribute(getAdminDataXMLNodeResult, "Serial", UpdatedData.Serial) == false) then
                ErrorData.Code = (-6)
            else
                AdminsData[adminLogin].Serial = UpdatedData.Serial
            end
        end

        if ((ErrorData.Code == 0) and (UpdatedData.Name ~= nil)) then
            if (xmlNodeSetAttribute(getAdminDataXMLNodeResult, "Name", UpdatedData.Name) == false) then
                ErrorData.Code = (-7)
            else
                AdminsData[adminLogin].Name = UpdatedData.Name
            end
        end

        if ((ErrorData.Code == 0) and (UpdatedData.BindingToSerial ~= nil)) then
            local bindingToSerialXML = "0"

            if (UpdatedData.BindingToSerial == true) then
                bindingToSerialXML = "1"
            end

            if (xmlNodeSetAttribute(getAdminDataXMLNodeResult, "BindingToSerial", bindingToSerialXML) == false) then
                ErrorData.Code = (-8)
            else
                AdminsData[adminLogin].BindingToSerial = UpdatedData.BindingToSerial

                table.insert(UpdateLogs, "Binding to serial: " .. bindingToSerialXML)
            end
        end

        if ((ErrorData.Code == 0) and (xmlSaveFile(AdminsDataXMLFile) == false)) then
            ErrorData.Code = (-9)
        end

        if (ErrorData.Code == 0) then
            if (#UpdateLogs > 0) then
                addDataToAdminsLog("[AC] UPDATE ADMIN. Admin Login: " .. adminLogin .. " (" .. table.concat(UpdateLogs, ", " ) .. ")")
            end

            fileCopy("data/admins_data.xml", "backups/admins_data.xml", true)
        else
            AdminsData[adminLogin] = LastAdminData
        end
    else
        ErrorData.Code = (-2)
    end

    xmlUnloadFile(AdminsDataXMLFile)

    if (ErrorData.Code ~= 0) then
        error(ErrorData)
    end
end


function loadAdminsData()
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    local AdminsDataXMLFile = xmlLoadFile("data/admins_data.xml")

    if (AdminsDataXMLFile == false) then
        ErrorData.Code = (-1)
        error(ErrorData)
    end

    local AdminsDataXMLFile_Admins = xmlNodeGetChildren(AdminsDataXMLFile)

    if (AdminsDataXMLFile_Admins == false) then
        xmlUnloadFile(AdminsDataXMLFile)
        ErrorData.Code = (-2)
        error(ErrorData)
    end

    for aKey, aValue in ipairs(AdminsDataXMLFile_Admins) do
        local adminACLGroup = xmlNodeGetAttribute(aValue, "ACLGroup")

        local adminIssued = xmlNodeGetAttribute(aValue, "Issued")

        local adminDateOfIssue = xmlNodeGetAttribute(aValue, "DateOfIssue")

        local adminTerm = xmlNodeGetAttribute(aValue, "Term")

        local adminBindingToSerial = xmlNodeGetAttribute(aValue, "BindingToSerial")

        local adminLogin = xmlNodeGetValue(aValue)

        if (adminACLGroup == false) then
            ErrorData.Code = (-3)
        elseif (adminIssued == false) then
            ErrorData.Code = (-4)
        elseif (adminDateOfIssue == false) then
            ErrorData.Code = (-5)
        elseif (adminTerm == false) then
            ErrorData.Code = (-6)
        elseif (adminBindingToSerial == false) then
            ErrorData.Code = (-7)
        elseif (adminLogin == false) then
            ErrorData.Code = (-8)
        end

        if (ErrorData.Code == 0) then
            local AdminData = {}

            AdminData.ACLGroup = adminACLGroup

            AdminData.Issued = adminIssued

            AdminData.DateOfIssue = tonumber(adminDateOfIssue)

            AdminData.Term = tonumber(adminTerm)

            if (adminBindingToSerial == "1") then
                AdminData.BindingToSerial = true
            else
                AdminData.BindingToSerial = false
            end

            local adminIP = xmlNodeGetAttribute(aValue, "IP")

            if (adminIP ~= false) then
                AdminData.IP = adminIP
            end

            local adminSerial = xmlNodeGetAttribute(aValue, "Serial")

            if (adminSerial ~= false) then
                AdminData.Serial = adminSerial
            end

            local adminName = xmlNodeGetAttribute(aValue, "Name")

            if (adminName ~= false) then
                AdminData.Name = adminName

                if ((getAccount(adminLogin) ~= false) and (getAccountPlayer(getAccount(adminLogin)) ~= false)) then
                    AdminData.CurrentUse = true
                else
                    AdminData.CurrentUse = false
                end
            end

            AdminsData[adminLogin] = AdminData
        else
            ErrorData.Key = aKey

            break
        end
    end

    xmlUnloadFile(AdminsDataXMLFile)

    if (ErrorData.Code ~= 0) then
       error(ErrorData)
    end
end


function loadACSettings()
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    local ACSettingsLoad = {
        AdminsDataCleanPeriod = get("AdminsDataCleanPeriod"),

        AllowedAdminsACLGroups = get("AllowedAdminsACLGroups"),

        WebMaxNumberOfRowsToShow = get("WebMaxNumberOfRowsToShow"),

        ClientOpenAdminsListButton = get("ClientOpenAdminsListButton"),

        ClientGUIScale = get("ClientGUIScale")
    }

    local acSettingsAmount = 0

    for acslKey, acslValue in pairs(ACSettingsLoad) do
        acSettingsAmount = acSettingsAmount + 1

        if (acslValue == false) then
            ErrorData.Code = (-1) * acSettingsAmount

            error(ErrorData)
        end
    end


    --Admins data clean period
    ACSettings.AdminsDataCleanPeriod = tonumber(ACSettingsLoad.AdminsDataCleanPeriod)

    if (ACSettings.AdminsDataCleanPeriod <= 0) then
        ErrorData.Code = (-1) * (acSettingsAmount + 1)

        error(ErrorData)
    end

    --Allowed admins ACL groups
    ACSettings.AllowedAdminsACLGroups = ACSettingsLoad.AllowedAdminsACLGroups

    for i, v in ipairs(ACSettings.AllowedAdminsACLGroups) do
        local aclGroupName = aclGetGroup(v)

        if ((aclGroupName == false) or (aclGroupName == nil)) then
            ErrorData.Code = (-1) * (acSettingsAmount + 2)

            error(ErrorData)
        end
    end

    --Web maximum number of rows to show.
    ACSettings.WebMaxNumberOfRowsToShow = tonumber(ACSettingsLoad.WebMaxNumberOfRowsToShow)

    if (ACSettings.WebMaxNumberOfRowsToShow <= 0) then
        ErrorData.Code = (-1) * (acSettingsAmount + 3)

        error(ErrorData)
    end

    --Client open admins list button
    ACSettings.ClientOpenAdminsListButton = tostring(ACSettingsLoad.ClientOpenAdminsListButton)

    --Client GUI ccale
    ACSettings.ClientGUIScale = tonumber(ACSettingsLoad.ClientGUIScale)

    if (ACSettings.ClientGUIScale <= 0) then
        ErrorData.Code = (-1) * (acSettingsAmount + 4)

        error(ErrorData)
    end
end

