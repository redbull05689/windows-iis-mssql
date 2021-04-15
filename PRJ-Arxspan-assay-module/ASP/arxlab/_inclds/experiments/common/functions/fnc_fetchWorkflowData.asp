<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="./fnc_workflowComms.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
appServiceEndpointUrl = getCompanySpecificSingleAppConfigSetting("appServiceEndpointUrl", session("companyId"))
configServiceEndpointUrl = getCompanySpecificSingleAppConfigSetting("configServiceEndpointUrl", session("companyId"))
linkServiceEndpointUrl = getCompanySpecificSingleAppConfigSetting("linkServiceEndpointUrl", session("companyId"))
' Makes a call to one of the services. Takes the service URL,
' data to submit, and the type of request to make.
function serviceCall(url, data, verb)
    Set http = CreateObject("MSXML2.ServerXMLHTTP")
    http.open verb, url, True
    http.setRequestHeader "Content-Type", "application/json"
    http.setRequestHeader "Content-Length", Len(data)
    http.setRequestHeader "Authorization", session("jwtToken")

    http.SetTimeouts 180000,180000,180000,180000
    ' ignore ssl cert errors
    http.setOption 2, 13056
    http.send data
    http.waitForResponse(180)
    serviceCall = http.responseText
end function

' Makes a GET call to one of the services. Takes the service URL.
function serviceGet(url)
    serviceGet = serviceCall(url, "", "GET")
end function

' Makes a POST call to one of the services. Takes the service URL,
' and data to submit.
function servicePost(url, inputModel)
    servicePost = serviceCall(url, inputModel, "POST")
end function

function configGet(url)
    resp = serviceGet(configServiceEndpointUrl & url)
    set workflowParse = JSON.parse(resp)
    configGet = workflowParse.Get("data")
end function

function appServiceGet(url)
	appServiceGet = serviceGet(appServiceEndpointUrl & url)
end function

' Makes a GET call to the link service. Takes the endpoint route.
function linkServiceGet(url)
    linkServiceGet = serviceGet(linkServiceEndpointUrl & url)
end function

' Makes a POST call to the link service. Takes the endpoint route, and data to POST.
function linkServicePost(url, inputModel)
    linkServicePost = servicePost(linkServiceEndpointUrl & url, inputModel)
end function

' Gets child links for the given parent. Takes the type code of the parent, the ID of the parent,
' the appName, the desired type code of the children, and the depth of the link-tree requested.
' childTypeId and depth are technically optional, so pass in 0 if they are not desired.
function getChildLinks(parentTypeId, parentId, appName, childTypeId, depth)

    linkUrl = "/links/parentTypeId/{parentTypeId}/parentId/{parentId}?appName={appName}"
    linkUrl = Replace(linkUrl, "{parentTypeId}", parentTypeId) 'TODO: figure out if we can get the type codes into the session or something.
    linkUrl = Replace(linkUrl, "{parentId}", parentId)
    linkUrl = Replace(linkUrl, "{appName}", appName)

    if depth > 0 then
        linkUrl = linkUrl & "&depth=" & depth
    end if

    if childTypeId > 0 then
        linkUrl = linkUrl & "&childTypeId=" & childTypeId
    end if

    getChildLinks = linkServiceGet(linkUrl)
end function

' Gets parent links for the given child. Takes the type code of the child, the ID of the child,
' the appName, the desired type code of the parents, and the depth of the link-tree requested.
' parentTypeId and depth are technically optional, so pass in 0 if they are not desired.
function getParentLinks(childTypeId, childId, appName, parentTypeId, depth)

    linkUrl = "/links/childTypeId/{childTypeId}/childId/{childId}?&appName={appName}"
    linkUrl = Replace(linkUrl, "{childTypeId}", childTypeId) 'TODO: figure out if we can get the type codes into the session or something.
    linkUrl = Replace(linkUrl, "{childId}", childId)
    linkUrl = Replace(linkUrl, "{appName}", appName)

    if depth > 0 then
        linkUrl = linkUrl & "&depth=" & depth
    end if

    if childTypeId > 0 then
        linkUrl = linkUrl & "&parentTypeId=" & parentTypeId
    end if

    getChildLinks = linkServiceGet(linkUrl)
end function

' Posts a link to the link service. Takes in the origin's type code, the origin's ID, the target's
' type code, the target's ID, the type of the link, the description for the link, and the appName.
function postLinkToSvc(originIdTypeCd, originId, targetIdTypeCd, targetId, linkTypeCd, description, appName)
    set linkJson = JSON.parse("{}")
    linkJson.set "companyId", session("companyId")
    linkJson.set "originIdTypeCd", CLNG(originIdTypeCd)
    linkJson.set "originId", CLNG(originId)
    linkJson.set "targetIdTypeCd", CLNG(targetIdTypeCd)
    linkJson.set "targetId", CLNG(targetId)
    linkJson.set "linkTypeCd", CLNG(linkTypeCd)
    linkJson.set "description", description

    set inputModel = JSON.parse("{}")
    inputModel.set "appName", appName
    inputModel.set "link", linkJson

    postLinkToSvc = linkServicePost("/links", JSON.stringify(inputModel))
end function

' Makes a GET request to the appSvc to fetch a list of request IDs that have the given
' users flagged as collaborators.
' collaboratorIds is a string made of the request IDs separated by commas.
function getRequestListFromCollaborators(collaboratorIds)
    collaboratorIds = replace(collaboratorIds, ",", "&UserIds=")
    collaboratorIds = "&UserIds=" & collaboratorIds

    getRequestListUrl = "/requests/getRequestListByCollaborators?appName=ELN" & collaboratorIds
    getRequestListFromCollaborators = appServiceGet(getRequestListUrl)
end function

' Makes a GET request to the appSvc to fetch metadata about a workflow file.
function getRequestFileMetadata(fileId, appName)
    apiEndpoint = "/fileAttachments/{fileId}?appName={appName}"
    apiEndpoint = Replace(apiEndpoint, "{fileId}", fileId)
    apiEndpoint = Replace(apiEndpoint, "{appName}", appName)
    getRequestFileMetadata = appServiceGet(apiEndpoint)
end function

%>