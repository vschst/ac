function loadTexts(textsFilePath)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    local TextsData = {}

    local TextsXMLFile = xmlLoadFile(textsFilePath)

    if (TextsXMLFile == false) then
        ErrorData.Code = (-1)

        error(ErrorData)
    end

    local TextsXMLFile_Texts = xmlNodeGetChildren(TextsXMLFile)

    if (TextsXMLFile_Texts == false) then
        xmlUnloadFile(TextsXMLFile)
        ErrorData.Code = (-2)
        error(ErrorData)
    end

    for tKey, tValue in ipairs(TextsXMLFile_Texts) do
        if (xmlNodeGetName(tValue) == "Group") then
            local groupName = xmlNodeGetAttribute(tValue, "Name")

            local GroupTexts = xmlNodeGetChildren(tValue)

            if (groupName == false) then
                ErrorData.Code = (-3)
            elseif (GroupTexts == false) then
                ErrorData.Code = (-4)
            end

            if (ErrorData.Code == 0) then
                TextsData[groupName] = {}

                for gtKey, gtValue in ipairs(GroupTexts) do
                    local loadTextDataFromXMLNodeStatus, loadTextDataFromXMLNodeResult = pcall(loadTextDataFromXMLNode, gtValue)

                    if (loadTextDataFromXMLNodeStatus == true) then
                        TextsData[groupName][loadTextDataFromXMLNodeResult.Name] = loadTextDataFromXMLNodeResult.Value
                    else
                        ErrorData.TextKey = tKey
                        ErrorData.GroupKey = gtKey
                        ErrorData.Code = (-7)

                        break
                    end
                end
            else
                ErrorData.TextKey = tKey
                ErrorData.Code = (-5)

                break
            end
        elseif (xmlNodeGetName(tValue) == "Text") then
            local loadTextDataFromXMLNodeStatus, loadTextDataFromXMLNodeResult = pcall(loadTextDataFromXMLNode, tValue)

            if (loadTextDataFromXMLNodeStatus == true) then
                TextsData[loadTextDataFromXMLNodeResult.Name] = loadTextDataFromXMLNodeResult.Value
            else
                ErrorData.TextKey = tKey
                ErrorData.Code = (-6)

                break
            end
        end
    end

    xmlUnloadFile(TextsXMLFile)

    if (ErrorData.Code ~= 0) then
        error(ErrorData)
    end

    return TextsData
end


function loadTextDataFromXMLNode(xmlNode)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0 }

    local TextData = {Name = xmlNodeGetAttribute(xmlNode, "Name"), Value = xmlNodeGetValue(xmlNode)}

    if (TextData.Name == false) then
        ErrorData.Code = (-1)
    elseif (TextData.Value == false) then
        ErrorData.Code = (-2)
    end

    if (ErrorData.Code == 0) then
        return TextData
    else
        error(ErrorData)
    end
end