function addAbandonedExperimentToProcQueue(experimentId, revisionNumber)

	Call getconnectedAdm
	'change the notebook description
	strQuery = "INSERT INTO pdfProcQueue (serverName, companyId, userId, experimentId, revisionNumber, fileName, fileType, experimentType,	filePath, jsonBody, dateCreated, dateProcessed, status)" &_
        "VALUES (?," &_
        "?," &_
        "?," &_
        "?," &_ 
        "?," &_
        "NULL" & "," &_
        "'abandoned'" & "," &_
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

end function
