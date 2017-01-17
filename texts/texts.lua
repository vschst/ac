function loadTexts(textsFilePath)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0}

    local TextsXMLFile = xmlLoadFile(textsFilePath)

    if (TextsXMLFile == false) then
        ErrorData.Code = (-1)

        error(ErrorData)
    end

    local TextsXMLFileNodes = xmlNodeGetChildren(TextsXMLFile)

    if (TextsXMLFileNodes == false) then
        xmlUnloadFile(TextsXMLFile)

        ErrorData.Code = (-2)
        error(ErrorData)
    end

    local getTextsDataStatus, TextsData = pcall(getTextsData, TextsXMLFileNodes, 0)

    if (getTextsDataStatus == false) then
        xmlUnloadFile(TextsXMLFile)

        outputServerLog("Load text file '".. textsFilePath .."' failed! Error in function: ".. TextsData.Source .." Error code: ".. TextsData.Code .." Depth: ".. TextsData.Depth .." Key: ".. TextsData.Key .."")

        ErrorData.Code = (-3)
        error(ErrorData)
    end

    xmlUnloadFile(TextsXMLFile)

    return TextsData
end


function getTextsData(XmlNodes, depth)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0, Depth = depth}

    local TextsObject = {}

    for nodeKey, nodeValue in ipairs(XmlNodes) do
        ErrorData.Key = nodeKey

        local nodeName = xmlNodeGetName(nodeValue)

        if (nodeName == false) then
            ErrorData.Code = (-1)
            error(ErrorData)
        end

        if (nodeName == "Text") then
            local TextData = getTextData(nodeValue, depth, nodeKey)

            TextsObject[TextData.Name] = TextData.Value
        elseif (nodeName == "Group") then
            local GroupData = getGroupData(nodeValue, depth, nodeKey)

            TextsObject[GroupData.Name] = getTextsData(GroupData.Value, depth + 1)
        end
    end

    return TextsObject
end


function getTextData(xmlNode, nodeDepth, nodeKey)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0, Depth = nodeDepth, Key = nodeKey}

    local TextData = {Name = xmlNodeGetAttribute(xmlNode, "Name"), Value = xmlNodeGetValue(xmlNode) }

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


function getGroupData(xmlNode, nodeDepth, nodeKey)
    local ErrorData = {Source = debug.getinfo(1, "n").name, Code = 0, Depth = nodeDepth, Key = nodeKey}

    local GroupData = {Name = xmlNodeGetAttribute(xmlNode, "Name"), Value = xmlNodeGetChildren(xmlNode) }

    if (GroupData.Name == false) then
        ErrorData.Code = (-1)
    elseif (GroupData.Value == false) then
        ErrorData.Code = (-2)
    end

    if (ErrorData.Code == 0) then
        return GroupData
    else
        error(ErrorData)
    end
end