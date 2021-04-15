<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%

' Helper function that converts the given object ID and type code into human-readable metadata
Function decode(objectId, objectTypeCd)
    
    ' Enums for the objectTypeCd
    requestCd          = 1
    regCd              = 2
    projectCd          = 3
    notebookCd         = 4
    experimentCd       = 5
    inventoryCd        = 6
    assayCd            = 7
    requestFieldCd     = 8
    requestItemFieldCd = 9

    ' Instantiate the return object as a JSON and set the ID and type code into it.
    set outputObj = JSON.parse("{}")
    outputObj.set "objectId", objectId
    outputObj.set "typeCd", objectTypeCd

    ' Now we'll use the type code to figure out which decoder function to use.
    if objectTypeCd = requestCd then
        decodeRequest(outputObj)
    elseif objectTypeCd = regCd then
        decodeReg(outputObj)
    elseif objectTypeCd = projectCd then
        decodeProject(outputObj)
    elseif objectTypeCd = notebookCd then
        decodeNotebook(outputObj)
    elseif objectTypeCd = experimentCd then
        decodeExperiment(outputObj)
    elseif objectTypeCd = inventoryCd then
        'placeholder
    elseif objectTypeCd = assayCd then
        'placeholder
    elseif objectTypeCd = requestFieldCd then
        call decodeRequestField(outputObj, false)
    elseif objectTypeCd = requestItemFieldCd then
        call decodeRequestField(outputObj, true)
    end if

    decode = JSON.stringify(outputObj)
End Function

' Takes the output object, retrieves the ID from it, and calls the appService to get information.
Function decodeRequest(outputObj)
    requestId = outputObj.get("objectId")

    requestUrl = "/requests/{requestId}?appName=ELN"
    requestUrl = Replace(requestUrl, "{requestId}", requestId)
    requestObj = appServiceGet(requestUrl)

    if requestObj <> "null" then
        Set requestData = JSON.parse(requestObj)

        userId = requestData.get("requestorId")
        if normalizeStr(userId) <> "" then
            Set rec = server.CreateObject("ADODB.recordset")    
            strQuery = "SELECT firstName, lastName FROM users WHERE id=" & SQLClean(userId, "N", "S")
            rec.open strQuery, connAdm, 3, 3
            if not rec.eof then
                outputObj.set "owner", rec("firstName") & " " & rec("lastName")
            end if
            rec.close
        end if

        outputObj.set "requestTypeId", normalizeStr(requestData.get("requestTypeId"))
        outputObj.set "linkId", requestId
        outputObj.set "linkName", normalizeStr(requestData.get("requestName"))
        outputObj.set "link", "workflow/viewIndividualRequest.asp"
    end if

End Function

' Takes the output object, retrieves the ID from it, and calls the DB to get information.
Function decodeReg(outputObj)

    cdId = outputObj.get("objectId")
    regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))

    Set rec = server.CreateObject("ADODB.recordset")
    strQuery = "SELECT reg_id " &_
        "FROM " & regMoleculesTable & " " &_
        "WHERE cd_id=" & cdId
    rec.open strQuery, jchemRegConn, 3, 3

    if not rec.eof then
        regId = CSTR(normalizeStr(rec("reg_id")))
        outputObj.set "linkId", regId
        outputObj.set "linkName", regId
        outputObj.set "link", "registration/showRegItem.asp"
    end if
    rec.close
    
End Function

' Takes the output object, retrieves the ID from it, and calls the DB to get information.
Function decodeProject(outputObj)

    projectId = outputObj.get("objectId")

    Set rec = server.CreateObject("ADODB.recordset")
    strQuery = "SELECT project.name AS name, " &_
        "project.description AS description, " &_
        "u.firstName, " &_
        "u.lastName " &_
        "FROM projects project " &_
        "JOIN users u " &_
            "ON project.userId=u.id " &_
        "WHERE project.id=" & SQLClean(projectId,"N","S")
    rec.open strQuery, connAdm, 3, 3

    if not rec.eof then
        outputObj.set "linkId", projectId
        outputObj.set "linkName", CSTR(normalizeStr(rec("name")))
        outputObj.set "linkDescription", CSTR(normalizeStr(rec("description")))
        outputObj.set "owner", rec("firstName") & " " & rec("lastName")
        outputObj.set "link", "show-project.asp"
    end if
    rec.close

End Function

' Takes the output object, retrieves the ID from it, and calls the DB to get information.
Function decodeNotebook(outputObj)

    notebookId = outputObj.get("objectId")

    Set rec = server.CreateObject("ADODB.recordset")
    strQuery = "SELECT n.name AS name, " &_
        "n.description AS description, " &_
        "u.firstName, " &_
        "u.lastName " &_
        "FROM notebooks n " &_
        "JOIN users u " &_
            "ON n.userId=u.id " &_
        "WHERE n.id=" & SQLClean(notebookId,"N","S")
    rec.open strQuery, connAdm, 3, 3

    if not rec.eof then
        outputObj.set "linkId", notebookId
        outputObj.set "linkName", CSTR(normalizeStr(rec("name")))
        outputObj.set "linkDescription", CSTR(normalizeStr(rec("description")))
        outputObj.set "owner", rec("firstName") & " " & rec("lastName")
        outputObj.set "link", "show-notebook.asp"
    end if
    rec.close

End Function

' Takes the output object, retrieves the ID from it, and calls the DB to get information.
Function decodeExperiment(outputObj)

    expId = outputObj.get("objectId")

    Set rec = server.CreateObject("ADODB.recordset")
    strQuery = "SELECT a.name AS name, " &_
        "a.legacyId AS experimentId, " &_
        "a.experimentType AS experimentType, " &_
        "a.details AS details, " &_
        "u.firstName, " &_
        "u.lastName " &_
        "FROM allExperiments a " &_
        "JOIN users u " &_
            "ON a.userId=u.id " &_
        "WHERE a.id=" & SQLClean(expId,"N","S")
    rec.open strQuery, connAdm, 3, 3

    if not rec.eof then
        outputObj.set "linkName", CSTR(normalizeStr(rec("name")))
        outputObj.set "linkId", CLNG(rec("experimentId"))
        outputObj.set "experimentType", CINT(rec("experimentType"))
        outputObj.set "linkDescription", CSTR(normalizeStr(rec("details")))
        outputObj.set "owner", rec("firstName") & " " & rec("lastName")

        prefix = GetPrefix(rec("experimentType"))
        link = GetExperimentPage(prefix)
        abr = GetAbbreviation(rec("experimentType"))
        outputObj.set "abr", abr
        outputObj.set "link", link

    end if
    rec.close

End Function

' Take a requestFieldValue or itemFieldValue and use it to decode the incoming link and get the related request id.
Function decodeRequestField(outputObj, itemField)
    requestFieldValueId = outputObj.get("objectId")

    if itemField = true then 
        requestUrl = "/requests/requestItemFieldValue/{valueId}?appName=ELN"
    else 
        requestUrl = "/requests/requestFieldValue/{valueId}?appName=ELN"
    end if 
    requestUrl = Replace(requestUrl, "{valueId}", requestFieldValueId)
    requestObj = appServiceGet(requestUrl)

    if requestObj <> "null" then
        Set requestData = JSON.parse(JSON.parse(requestObj).get("data"))

        userId = requestData.get("requestorId")
        if normalizeStr(userId) <> "" then
            Set rec = server.CreateObject("ADODB.recordset")    
            strQuery = "SELECT firstName, lastName FROM users WHERE id=" & SQLClean(userId, "N", "S")
            rec.open strQuery, connAdm, 3, 3
            if not rec.eof then
                outputObj.set "owner", rec("firstName") & " " & rec("lastName")
            end if
            rec.close
        end if
        
        outputObj.set "requestTypeId", normalizeStr(requestData.get("requestTypeId"))
        outputObj.set "linkId", normalizeStr(requestData.get("id"))
        outputObj.set "linkName", normalizeStr(requestData.get("requestName"))
        outputObj.set "link", "workflow/viewIndividualRequest.asp"
    end if

End Function

' Takes a record, checks if its null, and if it isn't, returns it. If it is, returns an empty string.
Function normalizeStr(dbStr)
    outStr = ""
    if not isnull(dbStr) then
        outStr = dbStr
    end if
    normalizeStr = outStr
End Function

%>