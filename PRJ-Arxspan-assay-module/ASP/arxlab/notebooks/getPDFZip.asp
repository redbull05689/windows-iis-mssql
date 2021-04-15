<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
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

    ' Fetch the requested zipFilePath otherwise.
    queueQuery = "SELECT zipFilePath " &_ 
        "FROM zipFileProcQueue " &_
        "WHERE id=?;"
    
    Set cmd = server.createobject("ADODB.Command")
    cmd.ActiveConnection = connAdm
    cmd.CommandText = queueQuery
    cmd.CommandType = adCmdText

    cmd.Parameters.Append(cmd.CreateParameter("@id", adInteger, adParamInput, len(queueId), queueId))
    set rs = cmd.execute
    zipFilePath = rs("zipFilePath")

    If zipFilePath <> "" then
        ' If we have one, deconstruct the filepath so we can get just the filename and download the file to the user.
        zipFileSplit = split(zipFilePath, "\")
        zipFile = zipFileSplit(UBound(zipFileSplit))

        Response.buffer = false
        Dim objStream
        Set objStream = Server.CreateObject("ADODB.Stream")
        objStream.Type = 1 'adTypeBinary
        objStream.Open
        objStream.LoadFromFile(zipFilePath)
        Response.ContentType  ="application/x-unknown"
        Response.Addheader "Content-Disposition", "attachment; filename=" & zipFile
        Response.BinaryWrite objStream.Read
        objStream.Close
        Set objStream = Nothing
    end if
%>