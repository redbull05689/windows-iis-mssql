<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->
<%
	server.scriptTimeout = 2500000
    
    ' Check the email blacklist from the adminSvc and determine whether or not
    ' the current user's email is blacklisted.
    emailBlackListStr = getCompanySpecificSingleAppConfigSetting("workflowBlacklistedEmailAddresses", session("companyId"))
    emailBlackList = split(emailBlackListStr, ",")

    emailIsBlacklisted = false

    for each email in emailBlackList
        lowerEmail = LCase(email)

        if lowerEmail = LCase(session("email")) then
            emailIsBlacklisted = true
            exit for
        end if
    next

    notebookId = request.queryString("notebookId")

    errStatus = false
    if not (session("canDownloadAllNotebookPDFs") and isNumeric(notebookId)) then
        errStatus = true
    elseif not cLng(notebookId) > 0 then
        ' This is a separate condition because the above condition won't shortcircuit if notebookId isn't numeric,
        ' so ASP owuld try to cast notebookId to a number.
        errStatus = true
    end if

    if errStatus then
        response.status = 403
        response.end
    end if

    ' Set up the main query for the allExperiments table. We're essentially running this query twice,
    ' but once is filtered against the list of visible experiments and the other is the list of experiments
    ' that the current user owns.
    baseQuery = "SELECT " &_
                    "a.name AS experimentName,  " &_
                    "n.name AS notebookName,  " &_
                    "a.legacyId,  " &_
                    "a.experimentType,  " &_
                    "a.revisionNumber,  " &_
                    "a.userId,  " &_
                    "e.abbrivName AS typeRoot  " &_
                "FROM allExperiments a (NOLOCK) " &_
                "{tempJoin} " &_
                "JOIN experimentTypes e  " &_
                    "ON a.experimentType=e.id  " &_
                "JOIN notebooks n  " &_
                    "ON a.notebookId=n.id  " &_
                "WHERE a.notebookId=? " &_
                "AND a.visible=1 "

    ' Get the list of visible experiments by running the stored procedure to fetch visible experiments,
    ' then store the results in a temp table. Run the baseQuery once, joining allExperiments on the tempTable
    ' to quickly get a list of visible experiments in this notebook, then run the query again to get everything
    ' the user owns and union the two result sets.
    notebookQuery = "DROP TABLE IF EXISTS #T; " &_
                    "SET NOCOUNT ON; " &_
                    "CREATE TABLE #T (uniqueId int, " &_
                        "experimentId int, " &_
                        "experimentType int); " &_
                    "INSERT #T EXEC elnGetVisibleExperiments @userId=?, @companyId=?; " &_
                    Replace(baseQuery, "{tempJoin}", "INNER JOIN #T t on a.id=t.uniqueId") &_
                    "UNION " &_
                    Replace(baseQuery, "{tempJoin}", "") &_
                    "AND a.userId=?;" &_
                    "DROP TABLE #T; "

    Set cmd = server.createobject("ADODB.Command")
    cmd.ActiveConnection = connAdm
    cmd.CommandText = notebookQuery
    cmd.CommandType = adCmdText

    cmd.Parameters.Append(cmd.CreateParameter("@userId1", adInteger, adParamInput, len(session("userId")), session("userId")))
    cmd.Parameters.Append(cmd.CreateParameter("@companyId", adInteger, adParamInput, len(session("companyId")), session("companyId")))
    cmd.Parameters.Append(cmd.CreateParameter("@notebookId1", adInteger, adParamInput, len(notebookId), notebookId))
    cmd.Parameters.Append(cmd.CreateParameter("@notebookId2", adInteger, adParamInput, len(notebookId), notebookId))
    cmd.Parameters.Append(cmd.CreateParameter("@userId2", adInteger, adParamInput, len(session("userId")), session("userId")))

    set notebookRec = cmd.execute

    if not notebookRec.eof then    
        notebookName = notebookRec("notebookName")
        queueId = writeToProcQueueTable(session("companyId"), session("userId"), notebookId, notebookName)
        q = writeToProcQueueFilesTable(queueId, notebookId)

        do while not notebookRec.eof

            experimentName = notebookRec("experimentName")
            experimentId = notebookRec("legacyId")
            experimentType = notebookRec("experimentType")
            revisionNumber = notebookRec("revisionNumber")
            userId = notebookRec("userId")
            typeRoot = notebookRec("typeRoot")

            fileExists = pdfExists(experimentId, experimentType, revisionNumber, false)

            if not fileExists then
                a = savePDF(experimentType, experimentId, revisionNumber, false, false, false)
            end if
            notebookRec.moveNext
        loop

        setRowToNewAndAddDownloadLink queueId, notebookId
    end if

    notebookRec.close
    set notebookRec = nothing

    response.write "Done!"
    response.end

    ' Helper function to build the path that the final ZIP file will live at.
    function buildZipPath(companyId, userId, notebookName)
        
        zipPath = "{uploadRootRoot}\{companyId}\{userId}\{notebookName}.zip"
        zipPath = Replace(zipPath, "{uploadRootRoot}", uploadRootRoot)
        zipPath = Replace(zipPath, "{companyId}", companyId)
        zipPath = Replace(zipPath, "{userId}", userId)
        zipPath = Replace(zipPath, "{notebookName}", notebookName)

        buildZipPath = zipPath
    end function

    ' Helper function to build the download URL to be written to the database.
    function buildDownloadUrl(queueId, notebookId)
    
        targetLinkBase = "https://{server}/arxlab/notebooks/download-pdfs.asp?id={queueId}&notebookId={notebookId}"
        targetLinkUrl = Replace(targetLinkBase, "{server}", Request.ServerVariables("SERVER_NAME"))
        targetLinkUrl = Replace(targetLinkUrl, "{queueId}", queueId)
        targetLinkUrl = Replace(targetLinkUrl, "{notebookId}", notebookId)

        buildDownloadUrl = targetLinkUrl
    end function

    ' Helper function to write a row to the zipFileProcQueue table.
    function writeToProcQueueTable(companyId, userId, notebookId, notebookName)

        ' Writing status 'INITIALIZED' here to ensure the service doesn't pick up this row too early and writing an
        ' empty string to the targetZipFileUrl for now because the row will need to be updated later and that URL requires
        ' the row's ID, which does not exist at the time of insertion..
        query = "INSERT INTO zipFileProcQueue " &_
                "(createUserId, dateCreated, dateUpdated, zipFilePath, status, emailRecipients, ccEmailRecipients, targetZipFileUrl) " &_
            "OUTPUT inserted.id AS queueId " &_
            "VALUES (?, GETDATE(), GETDATE(), ?, 'INITIALIZED', ?, NULL, '')"

        Set insCmd = server.createobject("ADODB.Command")
        insCmd.ActiveConnection = connAdm
        insCmd.CommandText = query
        insCmd.CommandType = adCmdText

        insCmd.Parameters.Append(insCmd.CreateParameter("@createUserId", adInteger, adParamInput, len(session("userId")), session("userId")))

        zipPath = buildZipPath(companyId, userId, notebookName)
        insCmd.Parameters.Append(insCmd.CreateParameter("@zipFilePath", adVarWChar, adParamInput, len(zipPath), zipPath))

        ' Defining the email param separately because we might need to null out the value.
        set emailParam = insCmd.CreateParameter("@emailRecipients", adVarWChar, adParamInput, len(session("email")), session("email"))
        if emailIsBlacklisted then
            emailParam.Value = Null
        end if
        insCmd.Parameters.Append(emailparam)

        set rs = insCmd.execute
        writeToProcQueueTable = rs("queueId")
    end function

    ' Helper function to write all experiment PDFs into the zipFileProcQueueFiles table.
    function writeToProcQueueFilesTable(queueId, notebookId)

        ' We're constructing the filePaths and the targetFileNames in the SELECT portion of the query so we can do this all in one fell swoop.
        ' We need the same list of experiments we crafted from the outside query, so we have to do the same paradigm of
        ' fetching the list of visible experiments, getting a resultSet based on that and then getting a resultSet based on
        ' the experiment's owner ID.
        baseFileQuery = "SELECT " &_ 
                            "?, " &_ 
                            "? + '/' + CAST(a.companyId AS varchar) + '/' + CAST(a.userId AS varchar) + '/' + CAST(a.legacyId AS varchar) + '/' + CAST(a.revisionNumber AS varchar) + '/' + e.abbrivName + '/sign.pdf'," &_ 
                            "a.name + '.pdf' " &_
                        "FROM allExperiments a " &_
                        "{tempJoin} " &_
                        "JOIN experimentTypes e " &_
                            "ON a.experimentType=e.id " &_
                        "WHERE a.notebookId=? " &_ 
                        "AND a.visible=1 "

        query = "DROP TABLE IF EXISTS #T; " &_
            "SET NOCOUNT ON; " &_
            "CREATE TABLE #T (uniqueId int, " &_
                "experimentId int, " &_
                "experimentType int); " &_
            "INSERT #T EXEC elnGetVisibleExperiments @userId=?, @companyId=?; " &_
            "INSERT INTO zipFileProcQueueFiles " &_
                "(zipFileProcQueueId, filePath, targetFileName) " &_
            Replace(baseFileQuery, "{tempJoin}", "INNER JOIN #T t ON a.id=t.uniqueId") &_
            "UNION " &_
            Replace(baseFileQuery, "{tempJoin}", "") &_
            "AND a.userId=?; " &_
            "DROP TABLE #T;"
        Set insCmd = server.CreateObject("ADODB.Command")
        insCmd.ActiveConnection = connAdm
        insCmd.CommandText = query
        insCmd.CommandType = adCmdText

        insCmd.Parameters.Append(insCmd.CreateParameter("@userId1", adInteger, adParamInput, len(session("userId")), session("userId")))
        insCmd.Parameters.Append(insCmd.CreateParameter("@companyId", adInteger, adParamInput, len(session("companyId")), session("companyId")))
        insCmd.Parameters.Append(insCmd.CreateParameter("@queueId1", adInteger, adParamInput, len(queueId), queueId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@uploadRoot1", adVarWChar, adParamInput, len(uploadRootRoot), uploadRootRoot))
        insCmd.Parameters.Append(insCmd.CreateParameter("@notebookId1", adInteger, adParamInput, len(notebookId), notebookId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@queueId2", adInteger, adParamInput, len(queueId), queueId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@uploadRoot2", adVarWChar, adParamInput, len(uploadRootRoot), uploadRootRoot))
        insCmd.Parameters.Append(insCmd.CreateParameter("@notebookId2", adInteger, adParamInput, len(notebookId), notebookId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@userId2", adInteger, adParamInput, len(session("userId")), session("userId")))

        set rs = insCmd.execute
    end function

    ' Helper function to set the given queue row's status to NEW and set the download link accordingly.
    ' Done out of band from the other query because the status is being set to NEW when everything else
    ' this is dependent on is in the queue and because the targetZipFileUrl requires the row ID.
    function setRowToNewAndAddDownloadLink(queueId, notebookId)
        query = "UPDATE zipFileProcQueue " &_
            "SET status='NEW', targetZipFileUrl=? " &_
            "WHERE id=?"

        downloadUrl = buildDownloadUrl(queueId, notebookId)
        
        Set insCmd = server.CreateObject("ADODB.Command")
        insCmd.ActiveConnection = connAdm
        insCmd.CommandText = query
        insCmd.CommandType = adCmdText
        insCmd.Parameters.Append(insCmd.CreateParameter("@downloadUrl", adVarWChar, adParamInput, len(downloadUrl), downloadUrl))
        insCmd.Parameters.Append(insCmd.CreateParameter("@queueId", adInteger, adParamInput, len(queueId), queueId))

        set rs = insCmd.execute
    end function
%>