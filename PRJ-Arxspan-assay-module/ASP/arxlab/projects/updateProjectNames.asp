<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
    projectIdList = request.form("projectIds")
    requestName = request.form("name")

    set projectIdJsonList = JSON.parse(projectIdList)
    set cleanProjectIdList = JSON.parse("[]")
    
    for i = 0 to projectIdJsonList.length - 1
        id = projectIdJsonList.get(i)
        cleanedId = SQLClean(id, "T", "N")
        cleanProjectIdList.push(cleanedId)

        ' We're sending invites here a little early because the actual update query
        ' does not take very long to run, so the potential window that someone sees an
        ' invite to a project that is not yet visible and clicks into said invitation
        ' should be incredibly tiny.
        Call sendProjectInvites(id, requestName)
    next

    updateQuery = "UPDATE projects" &_
    " SET name=" & SQLClean(requestName, "T", "S") & "," &_
    " visible=1" &_
    " WHERE id IN (" & cleanProjectIdList.join(",") & ")" &_
    " AND name='NONAME'" &_
    " AND visible=0;"

    Set updateRec = server.CreateObject("ADODB.Recordset")
    updateRec.open updateQuery, connAdm, 3, 3

    response.write "success"
    response.end

%>