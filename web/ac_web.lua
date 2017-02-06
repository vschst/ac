function webGetAdminsData()
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        local WebAdminsData = {}

        local AdminsDateOfIssueData = {}

        local numberOfAdmins = 0

        for adKey, adValue in pairs(AdminsData) do
            table.insert(AdminsDateOfIssueData, {Login = adKey, DateOfIssue = adValue.DateOfIssue})

            numberOfAdmins = numberOfAdmins + 1
        end

        if (numberOfAdmins > 0) then
            table.sort(AdminsDateOfIssueData,
                function(a, b)
                    return (a.DateOfIssue >  b.DateOfIssue)
                end
            )

            for adoiKey, adoiValue in ipairs(AdminsDateOfIssueData) do
                if (adoiKey <= ACSettings.WebMaxNumberOfRowsToShow) then
                    table.insert(WebAdminsData, {Login = adoiValue.Login, Data = webGetAdminData(adoiValue.Login)})
                else
                    break
                end
            end
        end

        returnTable.Response = {Data = WebAdminsData, NumberOfAdmins = numberOfAdmins}
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end

function webGetAdminData(adminLogin)
    local AdminData = {
        ACLGroup = AdminsData[adminLogin].ACLGroup,

        Issued = AdminsData[adminLogin].Issued,

        DateOfIssue = AdminsData[adminLogin].DateOfIssue,

        Term = AdminsData[adminLogin].Term,

        BindingToSerial = AdminsData[adminLogin].BindingToSerial
    }

    if (AdminsData[adminLogin].Name ~= nil) then
        AdminData.Name = AdminsData[adminLogin].Name
    end

    return AdminData
end


function webGetMoreAdminsData(minDateOfIssue)
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        if (minDateOfIssue ~= nil) then
            minDateOfIssue = tonumber(minDateOfIssue)

            local WebAdminsData = {}

            local AdminsDateOfIssueData = {}

            local numberOfAdmins = 0

            for adKey, adValue in pairs(AdminsData) do
                if (adValue.DateOfIssue < minDateOfIssue) then
                    table.insert(AdminsDateOfIssueData, {Login = adKey, DateOfIssue = adValue.DateOfIssue})
                end

                numberOfAdmins = numberOfAdmins + 1
            end

            if (numberOfAdmins > 0) then
                table.sort(AdminsDateOfIssueData,
                    function(a, b)
                        return (a.DateOfIssue >  b.DateOfIssue)
                    end
                )

                for adoiKey, adoiValue in ipairs(AdminsDateOfIssueData) do
                    if (adoiKey <= ACSettings.WebMaxNumberOfRowsToShow) then
                        table.insert(WebAdminsData, {Login = adoiValue.Login, Data = webGetAdminData(adoiValue.Login)})
                    else
                        break
                    end
                end
            end

            returnTable.Response = {Data = WebAdminsData, NumberOfAdmins = numberOfAdmins}
        else
            returnTable.ErrorCode = (-2)
        end
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function webAddNewAdmin(adminLogin, adminACLGroup, adminTerm, adminBindingToSerial)
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        userLogin = getAccountName(user)

        if (userLogin ~= false) then
            if (adminLogin == nil) then
                returnTable.ErrorCode = (-3)
            elseif (adminACLGroup == nil) then
                returnTable.ErrorCode = (-4)
            elseif (adminACLGroup == nil) then
                returnTable.ErrorCode = (-5)
            elseif (adminTerm == nil) then
                returnTable.ErrorCode = (-6)
            elseif (adminBindingToSerial == nil) then
                returnTable.ErrorCode = (-7)
            else
                local realTime = getRealTime();

                local NewAdminData = {
                    ACLGroup = adminACLGroup,

                    Issued = userLogin,

                    DateOfIssue = realTime.timestamp,

                    Term = tonumber(adminTerm),

                    BindingToSerial = adminBindingToSerial
                }

                local addNewAdminStatus = addNewAdmin(adminLogin, NewAdminData)

                if (addNewAdminStatus == 0) then
                    returnTable.Response = {Login = adminLogin, Data = webGetAdminData(adminLogin)}
                else
                    returnTable.ErrorCode = ((-7) + addNewAdminStatus)
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


function webRemoveAdmin(adminLogin)
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        if (adminLogin ~= nil) then
            local removeAdminStatus = removeAdmin(adminLogin)

            if (removeAdminStatus ~= 0) then
                returnTable.ErrorCode = ((-2) + removeAdminStatus)
            end
        else
            returnTable.ErrorCode = (-2)
        end
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function webEditAdmin(adminLogin, adminTerm, adminACLGroup, adminBindingToSerial)
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        userLogin = getAccountName(user)

        if (userLogin ~= false) then
            if ((adminLogin == nil) or (AdminsData[adminLogin] == nil)) then
                returnTable.ErrorCode = (-3)
            elseif (adminTerm == nil) then
                returnTable.ErrorCode = (-4)
            elseif (adminACLGroup == nil) then
                returnTable.ErrorCode = (-5)
            elseif (adminBindingToSerial == nil) then
                returnTable.ErrorCode = (-6)
            else
                adminTerm = tonumber(adminTerm)

                local ChangedAdminData = {}

                if (AdminsData[adminLogin].Term ~= adminTerm) then
                    ChangedAdminData.Term = adminTerm
                end

                if (AdminsData[adminLogin].ACLGroup ~= adminACLGroup) then
                    ChangedAdminData.ACLGroup = adminACLGroup
                end

                if (AdminsData[adminLogin].BindingToSerial ~= adminBindingToSerial) then
                    ChangedAdminData.BindingToSerial = adminBindingToSerial
                end

                local editAdminStatus = editAdmin(adminLogin, ChangedAdminData)

                if (editAdminStatus ~= 0) then
                    returnTable.ErrorCode = ((-6) + editAdminStatus)
                end

                returnTable.Response = ChangedAdminData
            end
        else
            returnTable.ErrorCode = (-2)
        end
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function webUpdateAddedAdmins(maxDateOfIssue)
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        if (maxDateOfIssue ~= nil) then
            maxDateOfIssue = tonumber(maxDateOfIssue)

            local WebAdminsData = {}

            local numberOfAdmins = 0

            for adKey, adValue in pairs(AdminsData) do
                if (adValue.DateOfIssue > maxDateOfIssue) then
                    table.insert(WebAdminsData, {Login = adKey, Data = webGetAdminData(adKey)})
                end

                numberOfAdmins = numberOfAdmins + 1
            end

            table.sort(WebAdminsData,
                function(a, b)
                    return (a.Data.DateOfIssue >  b.Data.DateOfIssue)
                end
            )

            returnTable.Response = {Data = WebAdminsData, NumberOfAdmins = numberOfAdmins}
        else
            returnTable.ErrorCode = (-2)
        end
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function webUpdateRemovedAdmins(LastAdminsLoginData)
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        if (LastAdminsLoginData ~= nil) then
            local RemovedAdminsLoginData = {}

            for laldKey, laldValue in ipairs(LastAdminsLoginData) do
                if (AdminsData[laldValue] == nil) then
                    table.insert(RemovedAdminsLoginData, laldValue)
                end
            end

            returnTable.Response = RemovedAdminsLoginData
        else
            returnTable.ErrorCode = (-2)
        end
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function webUpdateEditedAdmins(LastAdminsData)
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        if (LastAdminsData ~= nil) then
            local ChangedAdminsData = {}

            for ladKey, ladValue in pairs(LastAdminsData) do
                if ((ladValue.Login ~= nil) and (ladValue.Data ~= nil)) then
                    if (AdminsData[ladValue.Login] ~= nil) then
                        local ChangedAdmin = {Modified = false, Data = {} }

                        if (tonumber(ladValue.Data.Term) ~= AdminsData[ladValue.Login].Term) then
                            ChangedAdmin.Data.Term = AdminsData[ladValue.Login].Term

                            ChangedAdmin.Modified = true
                        end

                        if (ladValue.Data.ACLGroup ~= AdminsData[ladValue.Login].ACLGroup) then
                            ChangedAdmin.Data.ACLGroup = AdminsData[ladValue.Login].ACLGroup

                            ChangedAdmin.Modified = true
                        end

                        if (ladValue.Data.BindingToSerial ~= AdminsData[ladValue.Login].BindingToSerial) then
                            ChangedAdmin.Data.BindingToSerial = AdminsData[ladValue.Login].BindingToSerial

                            ChangedAdmin.Modified = true
                        end

                        if ((AdminsData[ladValue.Login].Name ~= nil) and ((ladValue.Data.Name == nil) or (ladValue.Data.Name ~= AdminsData[ladValue.Login].Name))) then
                            ChangedAdmin.Data.Name = AdminsData[ladValue.Login].Name

                            ChangedAdmin.Modified = true
                        end

                        if (ChangedAdmin.Modified == true) then
                            table.insert(ChangedAdminsData, {Login = ladValue.Login, Data = ChangedAdmin.Data})
                        end
                    end
                else
                    returnTable.ErrorCode = (-3)
                    returnTable.ErrorData = {Key = ladKey}

                    break
                end
            end

            returnTable.Response = ChangedAdminsData
        else
            returnTable.ErrorCode = (-2)
        end
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function webGetAllowedAdminsACLGroups()
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        returnTable.Response = ACSettings.AllowedAdminsACLGroups
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end


function webGetTexts()
    local returnTable = {}

    returnTable.ErrorCode = 0

    if (ACServerLoad == true) then
        returnTable.Response = TextsWeb
    else
        returnTable.ErrorCode = (-1)
    end

    return returnTable
end