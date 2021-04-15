<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%

    set expIdList = JSON.parse(request.form("experimentIdList"))
    requestId = request.form("requestId")

    for i=0 to expIdList.length - 1
        set experimentInfo = expIdList.get(i)
        experimentId = experimentInfo.get("id")
        experimentType = experimentInfo.get("index")

        if experimentType = "chem" then
            experimentType = ""
        end if

        typeId = GetTypeId(experimentType)

        strQuery = "IF NOT EXISTS (SELECT id " &_
                                    "FROM experimentRequests " &_
                                    "WHERE experimentId = " & SQLCLEAN(experimentId, "N", "N") & " " &_
                                    "AND experimentType = " & SQLCLEAN(typeId, "N", "N") & " " &_
                                    "AND requestId = " & SQLCLEAN(requestId, "N", "N") & ") " &_
                    "INSERT INTO experimentRequests (experimentId, experimentType, requestId, comments) VALUES (" &_
                    SQLCLEAN(experimentId, "N", "N") & ", " & SQLCLEAN(typeId, "N", "N") & ", '" & SQLCLEAN(requestId, "N", "N") & "', 'Linked from request.')"
        Set rec = server.CreateObject("ADODB.RecordSet")
        rec.open strQuery, connAdm, 3, 3
        set rec = nothing
    next

    ' Initialize the return object here.
    set returnObj = JSON.parse("{}")
    returnObj.set "success", true
    response.write JSON.stringify(returnObj)
%>