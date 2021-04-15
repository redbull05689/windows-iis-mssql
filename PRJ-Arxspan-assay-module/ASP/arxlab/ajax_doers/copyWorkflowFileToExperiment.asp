<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
    requestFileId = request.querystring("fileId")
    experimentId = request.querystring("id")
    experimentType = request.querystring("type")
    ownerId = request.querystring("ownerId")

    if not (IsNumeric(requestFileId) and IsNumeric(experimentId) and IsNumeric(experimentType) and IsNumeric(ownerId)) then
        response.write "Incorrect input parameters passed to copyWorkflowFileToExperiment."
        response.end
    end if

    notebookId = getNotebookId(experimentId, experimentType)
    canWrite = canWriteNotebook(notebookId)
    ownsExp = ownsExperiment(experimentType,experimentId,session("userId"))

    if experimentType = "5" then
        callingMethod = "copyWorkflowFileToExperiment"
        isCoAuthor = checkCoAuthors(experimentId, experimentType, callingMethod)
        canWrite = isCoAuthor or ownsExp
    end if

    if not canWrite then
        response.write "writeError"
        response.end
    end if
%>

<!-- #include file="../_inclds/experiments/cust/asp/check-existing-draft.asp"-->

<%
    ' If the current user cannot write to the experiment at this moment, then the operation fails.
    if draftExists then
        response.write "draftError"
        response.end
    end if

    ' Fetch the metadata for the given file ID.
    fileJsonStr = getRequestFileMetadata(requestFileId, "ELN")
    set fileJson = JSON.parse(fileJsonStr)

    result = fileJson.get("result")

    ' If we have a successful response, then continue.
    if result = "success" then
        dataStr = fileJson.get("data")

        ' Make sure there is metadata for the file and if there isn't, end the operation.
        if dataStr = "null" then
            response.write "fileNonexistenceError"
            response.end
        end if

        set dataJson = JSON.parse(dataStr)
        
        origFileName = dataJson.get("fileName")
        fileName = dataJson.get("actualFileName")
        fileType = dataJson.get("fileExtension")
        requestOwnerId = dataJson.get("userId")

        ' Construct the path for the original workflow file, then make sure the file exists at the specified location.
        origFileLocation = "{uploadRoot}\workflow_uploads\{userId}\{actualFilename}"
        origFileLocation = Replace(origFileLocation, "{uploadRoot}", uploadRoot)
        origFileLocation = Replace(origFileLocation, "{userId}", requestOwnerId)
        origFileLocation = Replace(origFileLocation, "{actualFilename}", fileName)

        set fs = Server.CreateObject("Scripting.FileSystemObject")
        if fs.FileExists(origFileLocation) Then

            ' Add 1 to the current revision.
            currentRevision = getExperimentRevisionNumber(experimentType,experimentId) + 1

            ' Grab both the experiment prefix and the abbreviation, we need both because experiment type 1 has no prefix
            ' so the abbrivation is necessary for the file system.
            expPrefix = getPrefix(experimentType)
            expAbbrv = getAbbreviation(experimentType)
            fileNameNoExt = Replace(fileName, fileType, "")
            fileType = Replace(fileType, ".", "")

            ' Construct the path for the current experiment, then add the file name to the file location.
            newFileDirectory = "{uploadRoot}\{userId}\{experimentId}\{revisionId}\{type}\"
            newFileDirectory = Replace(newFileDirectory, "{uploadRoot}", uploadRoot)
            newFileDirectory = Replace(newFileDirectory, "{userId}", ownerId)
            newFileDirectory = Replace(newFileDirectory, "{experimentId}", experimentId)
            newFileDirectory = Replace(newFileDirectory, "{revisionId}", currentRevision)
            newFileDirectory = Replace(newFileDirectory, "{type}", expAbbrv)
            
            newFileLocation = newFileDirectory & fileName

            ' If the file doesn't exist for the current experiment and revision, then begin the copy operation.
            if not fs.FileExists(newFileLocation) then

                ' Make sure this new directory exists and then copy the file over.
                recursiveDirectoryCreate uploadRootRoot, newFileDirectory
                fs.CopyFile origFileLocation, newFileLocation

                ' Figure out the size of the file and how many KB it is.
                fileBytes = fs.getFile(newFileLocation).size
                if fileBytes > 1024 then
                    fileSize = CStr(CLng(fileBytes / 1024)) & " K"
                else
                    fileSize = CStr(fileBytes) & " B"
                end if

                ' Write the file data to the preSave and the pdf queue tables.
                insertIntoPreSaveTable expPrefix, experimentId, origFileName, fileName, currentRevision, fileSize, fileBytes
                insertIntoPdfProcQueue experimentId, currentRevision, fileNameNoExt, fileType, expAbbrv, newFileDirectory
                Response.Write "Success!"
                Response.End
            else
                Response.write "fileExistsError"
                Response.end
            end if
        Else
            response.write "fileNonexistenceError"
            response.end
        End if
    Else
        response.write "fileNonexistenceError"
        response.end
    End if

    ' Write the given file information into the pdfProcQueue table.
    function insertIntoPdfProcQueue(experimentId, revisionId, fileName, fileType, typePrefix, filePath)
        pdfQuery = "INSERT INTO pdfProcQueue " &_
            "(serverName, " &_
            "companyId, " &_
            "userId, " &_
            "experimentId, " &_
            "revisionNumber, " &_
            "fileName, " &_
            "fileType, " &_
            "experimentType, " &_
            "filePath, " &_
            "dateCreated, " &_
            "status) " &_
            "VALUES " &_
            "(?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), 'NEWPYTHON')"

        Set insCmd = server.createobject("ADODB.Command")
        insCmd.ActiveConnection = connAdm
        insCmd.CommandText = pdfQuery
        insCmd.CommandType = adCmdText

        insCmd.Parameters.Append(insCmd.CreateParameter("@serverName", adVarWChar, adParamInput, len(whichServer), whichServer))
        insCmd.Parameters.Append(insCmd.CreateParameter("@companyId", adInteger, adParamInput, len(session("companyId")), session("companyId")))
        insCmd.Parameters.Append(insCmd.CreateParameter("@userId", adInteger, adParamInput, len(session("userId")), session("userId")))
        insCmd.Parameters.Append(insCmd.CreateParameter("@experimentId", adInteger, adParamInput, len(experimentId), experimentId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@revisionNumber", adInteger, adParamInput, len(revisionId), revisionId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@fileName", adVarWChar, adParamInput, len(fileName), fileName))
        insCmd.Parameters.Append(insCmd.CreateParameter("@fileType", adVarWChar, adParamInput, len(fileType), fileType))
        insCmd.Parameters.Append(insCmd.CreateParameter("@experimentType", adVarWChar, adParamInput, len(typePrefix), typePrefix))
        insCmd.Parameters.Append(insCmd.CreateParameter("@filePath", adVarWChar, adParamInput, len(filePath), filePath))

        set rs = insCmd.execute
    end function

    ' Write the given file information into the experiment preSave table.
    function insertIntoPreSaveTable(typePrefix, experimentId, fileName, actualFileName, revisionId, filesize, totalBytes)
        attachmentsPreSaveTable = GetFullName(typePrefix, "attachments_preSave", true)
        preSaveQuery = "INSERT INTO {preSaveTable} " &_
            "(userId, " &_
            "experimentId, " &_
            "name, " &_
            "filename, " &_
            "actualFileName, " &_
            "revisionNumber, " &_
            "dateUploaded, " &_
            "filesize, " &_
            "totalBytes, " &_
            "dateUploadedServer, " &_
            "sortOrder, " &_
            "folderId) " &_
            "VALUES " &_
            "(?, ?, ?, ?, ?, ?, GETUTCDATE(), ?, ?, GETDATE(), -1, 0)"
        
        preSaveQuery = Replace(preSaveQuery, "{preSaveTable}", attachmentsPreSaveTable)
        
        Set insCmd = server.createobject("ADODB.Command")
        insCmd.ActiveConnection = connAdm
        insCmd.CommandText = preSaveQuery
        insCmd.CommandType = adCmdText

        insCmd.Parameters.Append(insCmd.CreateParameter("@userId", adInteger, adParamInput, len(session("userId")), session("userId")))
        insCmd.Parameters.Append(insCmd.CreateParameter("@experimentId", adInteger, adParamInput, len(experimentId), experimentId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@name", adVarWChar, adParamInput, len(fileName), fileName))
        insCmd.Parameters.Append(insCmd.CreateParameter("@filename", adVarWChar, adParamInput, len(fileName), fileName))
        insCmd.Parameters.Append(insCmd.CreateParameter("@actualFileName", adVarWChar, adParamInput, len(actualFileName), actualFileName))
        insCmd.Parameters.Append(insCmd.CreateParameter("@revisionNumber", adVarWChar, adParamInput, len(revisionId), revisionId))
        insCmd.Parameters.Append(insCmd.CreateParameter("@filesize", adVarWChar, adParamInput, len(filesize), filesize))
        insCmd.Parameters.Append(insCmd.CreateParameter("@totalBytes", adInteger, adParamInput, len(totalBytes), totalBytes))

        set rs = insCmd.execute
    end function
%>