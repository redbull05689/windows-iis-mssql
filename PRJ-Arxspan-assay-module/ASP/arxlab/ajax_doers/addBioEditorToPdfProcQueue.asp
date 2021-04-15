<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%
    ' This file is to take in some vars about a bio editor in an experiment and add it to the pdfProcQueue.
    ' This will generate a png for the editor to be used in the final pdf. 
    expId = request.form("expId")
    revNumber = request.form("revisionNumber")
    editorId = request.form("editorId")

    Set editorJson = JSON.parse("{}")
    editorJson.Set "editorId", editorId

    if expId = "" or revNumber = "" or revNumber = "" then
        response.write "Bad input."
        response.end
    end if 

	Call getconnectedAdm
	'change the notebook description
	strQuery = "INSERT INTO pdfProcQueue (serverName, companyId, userId, experimentId, revisionNumber, fileName, fileType, experimentType,	filePath, jsonBody, dateCreated, dateProcessed, status)" &_
        "VALUES (?," &_
        "?," &_
        "?," &_
        "?," &_ 
        "?," &_
        "NULL" & "," &_
        "'bioSpn'" & "," &_
        "'bio'" & "," &_
        "NULL" & "," &_
        "?," &_
        "GETDATE()" & "," &_ 
        "NULL" & "," &_
        "'NEW')"
        
    Set cmd = server.createobject("ADODB.Command")
    cmd.ActiveConnection = connAdm
    cmd.CommandText = strQuery
    cmd.CommandType = adCmdText

    cmd.Parameters.Append(cmd.CreateParameter("@whichServer", adVarWChar, adParamInput, len(whichServer), whichServer))
    cmd.Parameters.Append(cmd.CreateParameter("@companyId", adInteger, adParamInput, len(session("companyId")), session("companyId")))
    cmd.Parameters.Append(cmd.CreateParameter("@userId", adInteger, adParamInput, len(session("userId")), session("userId")))
    cmd.Parameters.Append(cmd.CreateParameter("@expId", adInteger, adParamInput, len(expId), expId))
    cmd.Parameters.Append(cmd.CreateParameter("@revNumber", adInteger, adParamInput, len(revNumber), revNumber))
    cmd.Parameters.Append(cmd.CreateParameter("@editorJson", adVarWChar, adParamInput, len(JSON.Stringify(editorJson)), JSON.Stringify(editorJson)))

    set notebookRec = cmd.execute
	Call disconnectadm

    response.write "Done"
%>