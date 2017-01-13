function addNewAdmin(adminLogin, NewAdminData)
    local ErrorCode = 0

    if (ACServerLoad == true) then
        if ((adminLogin == nil) or (getAccount(adminLogin) == false) or (AdminsData[adminLogin] ~= nil)) then
            ErrorCode = (-2)
        elseif ((NewAdminData.ACLGroup == nil) or (isACLGroupAllowed(NewAdminData.ACLGroup) == false)) then
            ErrorCode = (-3)
        elseif (NewAdminData.Issued == nil) then
            ErrorCode = (-4)
        elseif ((NewAdminData.DateOfIssue == nil) or (NewAdminData.DateOfIssue <= 0)) then
            ErrorCode = (-5)
        elseif ((NewAdminData.Term == nil) or (NewAdminData.Term <= 0)) then
            ErrorCode = (-6)
        elseif (NewAdminData.BindingToSerial == nil) then
            ErrorCode = (-7)
        else
            local addNewAdminDataStatus, addNewAdminDataResult = pcall(addNewAdminData, adminLogin, NewAdminData)

            if (addNewAdminDataStatus == true) then
                aclGroupAddObject(aclGetGroup(NewAdminData.ACLGroup), "user."..adminLogin)
            else
                triggerEvent("ACErrorOutput", root,  {Type = "function", Name = addNewAdminDataResult.Source}, addNewAdminDataResult.Code)

                ErrorCode = (-8)
            end
        end
    else
        ErrorCode = (-1)
    end

    return ErrorCode
end


function removeAdmin(adminLogin)
    local ErrorCode = 0

    if (ACServerLoad == true) then
        if ((adminLogin ~= nil) and (AdminsData[adminLogin] ~= nil)) then
            local adminACLGroup = AdminsData[adminLogin].ACLGroup

            local adminName = AdminsData[adminLogin].Name

            local removeAdminDataStatus, removeAdminDataResult = pcall(removeAdminData, adminLogin)

            if (removeAdminDataStatus == true) then
                aclGroupRemoveObject (aclGetGroup(adminACLGroup), "user."..adminLogin)

                if (adminName ~= nil) then
                    for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                        if (aclpValue == 2) then
                            triggerClientEvent(aclpKey, "DeleteAdminsListData", aclpKey, md5(adminLogin))
                        end
                    end
                end
            else
                triggerEvent("ACErrorOutput", root,  {Type = "function", Name = removeAdminDataResult.Source}, removeAdminDataResult.Code)

                ErrorCode = (-3)
            end
        else
            ErrorCode = (-2)
        end
    else
        ErrorCode = (-1)
    end

    return ErrorCode
end


function updateAdmin(adminLogin, UpdatedData)
    local ErrorCode = 0

    if (ACServerLoad == true) then
        if ((adminLogin ~= nil) and (AdminsData[adminLogin] ~= nil)) then
            local updateAdminsListDataOnClient = false

            if (AdminsData[adminLogin].Name ~= nil) then
                updateAdminsListDataOnClient = true
            end

            local lastAdminACLGroup = AdminsData[adminLogin].ACLGroup

            local updateAdminDataStatus, updateAdminDataResult = pcall(updateAdminData, adminLogin, UpdatedData)

            if (updateAdminDataStatus == true) then
                if (UpdatedData.ACLGroup ~= nil) then
                    aclGroupRemoveObject(aclGetGroup(lastAdminACLGroup), "user."..adminLogin)

                    aclGroupAddObject(aclGetGroup(UpdatedData.ACLGroup), "user."..adminLogin)
                end

                if (updateAdminsListDataOnClient == true) then
                    local UpdatedDataClient = {}

                    if (UpdatedData.Name ~= nil) then
                        UpdatedDataClient.Name = AdminsData[adminLogin].Name
                    end

                    if (UpdatedData.ACLGroup ~= nil) then
                        UpdatedDataClient.ACLGroup = AdminsData[adminLogin].ACLGroup
                    end

                    if (UpdatedData.Term ~= nil) then
                        UpdatedDataClient.DateOfRemoval = (AdminsData[adminLogin].DateOfIssue + (AdminsData[adminLogin].Term * 86400))
                    end

                    for aclpKey, aclpValue in pairs(ACLoadedPlayers) do
                        if (aclpValue == 2) then
                            triggerClientEvent(aclpKey, "UpdateAdminsListData", aclpKey, md5(adminLogin), UpdatedDataClient)
                        end
                    end
                end
            else
                triggerEvent("ACErrorOutput", root,  {Type = "function", Name = updateAdminDataResult.Source}, updateAdminDataResult.Code)

                ErrorCode = (-3)
            end
        else
            ErrorCode = (-2)
        end
    else
        ErrorCode = (-1)
    end

    return ErrorCode
end


function isPlayerAnAdmin(thePlayer)
    local returnTable = {ErrorCode = 0, IsAdmin = false}

    if (ACServerLoad == true) then
        local playerAccount = getPlayerAccount(thePlayer)

        local playerIP = getPlayerIP(thePlayer)

        local playerSerial = getPlayerSerial(thePlayer)

        if ((playerAccount ~= false) and (playerIP ~= false) and (playerSerial ~= false)) then
            if (isGuestAccount(playerAccount) == false) then
                local playerLogin = getAccountName(playerAccount)

                if (playerLogin ~= false) then
                    if (AdminsData[playerLogin] ~= nil) then
                        returnTable.IsAdmin = true
                    end
                else
                    ErrorCode = (-3)
                end
            else
                for adKey, adValue in pairs(AdminsData) do
                    if (((adValue.IP ~= nil) and (adValue.IP == playerIP)) or ((adValue.Serial ~= nil) and (adValue.Serial == playerSerial))) then
                        returnTable.IsAdmin = true

                        break
                    end
                end
            end
        else
            returnTable.ErrorCode = (-2)
        end
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function isACLGroupAllowed(aclGroupName)
    local allowed = false

    for i, v in ipairs(ACSettings.AllowedAdminsACLGroups) do
        if (v == aclGroupName) then
            allowed = true

            break
        end
    end

    return allowed
end