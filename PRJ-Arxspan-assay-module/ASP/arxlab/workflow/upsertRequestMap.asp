<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%

    itemId = request.queryString("itemId")
    requestId = request.queryString("requestId")
    dataTypeId = request.queryString("dataType")

    idType = 0

    ' Initialize the return object here.
    set returnObj = JSON.parse("{}")
    returnObj.set "success", false

    ' If we have valid IDs to look for, then move on.
    if (itemId <> -1 and itemId <> "") and requestId <> -1 then
        ' The only valid data types are 13 (notebook) and 14 (project)
        if dataTypeId = 13 then
            idType = 4
        elseif dataTypeId = 14 then
            idType = 3
        else
            ' Abort if other.
            response.write JSON.stringify(returnObj)
            response.end
        end if

        if idType > 0 then
        
			' The first magic number is the target type code and the second is the link type.
			' Type Codes:
			' 1 - Request
			' 2 - Reg
			' 3 - Project
			' 4 - Notebook
			' 5 - Experiment
			' 6 - Inventory
			' 7 - Assay
			' Link Types:
			' 1 - Reference
			' 2 - Hierarchical
            linkPost = postLinkToSvc(idType, itemId, 1, requestId, 1, "Created by request ID: " & requestId, "Workflow")
            returnObj.set "success", true
            returnObj.set "result", linkPost
        end if
    end if

    response.write JSON.stringify(returnObj)
%>