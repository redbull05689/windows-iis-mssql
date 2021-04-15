<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<%
    hasAnalExperiment = getCompanySpecificSingleAppConfigSetting("hasAnalyticalExperiments", session("companyId"))
	blockNewColab = getCompanySpecificSingleAppConfigSetting("disableFreeExps", session("companyId"))
	hasFreeExperiment = getCompanySpecificSingleAppConfigSetting("hasFreeExperiments", session("companyId"))

    ' Helper function to create an object with the data for every experiment type.
    Function createOptionObj(name, href, id)
        set optionObj = JSON.parse("{}")
        optionObj.set "name", server.HTMLEncode(name)
        optionObj.set "href", href
        optionObj.set "id", id
        set createOptionObj = optionObj
    End function

    ' Initialize our return object, our list of experiment types and the default val.
    set expTypeObj = JSON.parse("{}")
    set expTypeList = JSON.parse("[]")

    ' Default val will be the href link for whichever experiment type matches session("defaultExperimentType").
    defaultVal = ""

    ' Default type val will be the exp type for whichever experiment type matches session("defaultExperimentType").
    defaultTypeVal = ""

    ' Chemistry experiment.
    if session("hasChemistry") and not session("hideNonCollabExperiments") then
        set chemObj = createOptionObj("Chemistry", "/arxlab/experiment.asp", 1)
        if session("defaultExperimentType") = 1 then
            defaultVal = chemObj.get("href")
            defaultTypeVal = 1
        end if
        expTypeList.push(chemObj)
    end if

    ' Biology experiment.
    if not session("hideNonCollabExperiments") then
        set bioObj = createOptionObj("Biology", "/arxlab/bio-experiment.asp", 2)
        if session("defaultExperimentType") = 2 then
            defaultVal = bioObj.get("href")
            defaultTypeVal = 2
        end if
        expTypeList.push(bioObj)
    end if

    ' Concept experiment.
    if hasFreeExperiment and not blockNewColab then
        freeName = "Concept"
        if session("hasMUFExperiment") then
            freeName = mufName
        end if

        set freeObj = createOptionObj(freeName, "/arxlab/free-experiment.asp", 3)
        if session("defaultExperimentType") = 3 then
            defaultVal = freeObj.get("href")
            defaultTypeVal = 3
        end if
        expTypeList.push(freeObj)
    end if

    ' Analytical experiment.
    if hasAnalExperiment and not session("hideNonCollabExperiments") then
        set analObj = createOptionObj("Analytical", "/arxlab/anal-experiment.asp", 4)
        if session("defaultExperimentType") = 4 then
            defaultVal = analObj.get("href")
            defaultTypeVal = 4
        end if
        expTypeList.push(analObj)
    end if

    ' Now fetch the request types that we're allowed to add from the ELN.
    custExpTypesStr = configGet("/requesttypes/requestTypeNamesByPermissionType?appName=ELN&permissionType=canAdd&includeDisabled=false")
    set custExpTypesList = JSON.parse(custExpTypesStr)
    
    set custList = JSON.parse("[]")
    for i=0 to custExpTypesList.length - 1
        set custExpType = custExpTypesList.get(i)
        custUrl = "/arxlab/cust-experiment.asp?r=" & custExpType.get("id")
        set custExpObj = createOptionObj(custExpType.get("displayName"), custUrl, custExpType.get("id"))
        custExpId = CInt(custExpType.get("id"))

        ' Cust experiments use the requestTypeID + 5000 as the default experiment type so as to avoid collisions with
        ' the original four experiment types, so we can either subtract 5000 from the defaultExperimentType and compare that
        ' to the requestTypeID or add 5000 to the requestTypeID and compare that to the defaultExperimentType.
        if session("defaultExperimentType") - 5000 = custExpId then
            defaultVal = custExpObj.get("href")
            defaultTypeVal = "5:" & custExpId
        end if
        custList.push(custExpObj)
    next

    ' Set everything into the expTypeObj, stringify it and return it.
    expTypeObj.set "defaultTypeList", expTypeList
    expTypeObj.set "custTypeList", custList
    expTypeObj.set "default", defaultVal
    expTypeObj.set "defaultType", defaultTypeVal
    response.write JSON.stringify(expTypeObj)
    response.end
%>