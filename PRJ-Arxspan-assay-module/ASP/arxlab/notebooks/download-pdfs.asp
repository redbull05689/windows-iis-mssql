<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<%
    queueId = request.querystring("id")
    notebookId = request.querystring("notebookId")

    canRead = canReadNotebook(notebookId,session("userId")) or canWriteNotebook(notebookId)

    ' Error out if the current user is not allowed to read the requested notebook or the query params are wrong.
    errStatus = false
    if not (canRead and isNumeric(notebookId) and isNumeric(queueId)) then
        errStatus = true
    elseif not (cLng(notebookId) > 0 and cLng(queueId) > 0) then
        ' This is a separate condition because if either notebookId or queueId aren't numeric, the lone does not short circuit
        ' on those conditions and will attempt to cast these two IDs to numbers when they are clearly not.
        errStatus = true
    end if

    if errStatus then
        response.status = 403
        response.end
    end if

    if not canRead then
        %>
        You are not authorized to view this page.
        <%
    else
        %>
        <h1>Download PDFs</h1>
        <span>Click <a href="getPDFZip.asp?id=<%=queueId%>&notebookId=<%=notebookId%>">here</a> to download the zip file for the requested notebook's PDFs.</span>
        <%
    end if
%>
<!-- #include file="../_inclds/footer-tool.asp"-->