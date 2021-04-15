<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getCoAuthors(experimentId, experimentType, revisionNumber)
	getCoAuthors = ""
    hasRevision = (revisionNumber <> "")

    if experimentType = "5" then
        table = "custExperiments"
        
        if hasRevision then
            table = table & "_history"
        end if

        strQuery = "SELECT requestId, requestRevisionNumber, requestTypeId, userId " &_
                    "FROM " & table & " "

        if hasRevision then
            strQuery = strQuery & "WHERE experimentId=" & experimentId & " " &_
                        "AND revisionNumber = " & revisionNumber
        else 
            strQuery = strQuery & "WHERE id=" & experimentId
        end if
        
        Set rec = server.CreateObject("ADODB.RecordSet")
        rec.open strQuery, connadm, 3, 3

        if not rec.eof then
            getCoAuthors = rec("userId")
            reqId = rec("requestId")
            revId = rec("requestRevisionNumber")
            reqType = rec("requestTypeId")

            if reqId <> "" and not isnull(revId) then

                ' Make a workflow request with the request Id and request revision, then get right to the information we want.
                coAuthUrl = "/requests/{requestId}/getCollaborators?appName=ELN"
                coAuthUrl = Replace(coAuthUrl, "{requestId}", reqId)

                workflowData = appServiceGet(coAuthUrl)
                set workflowJson = JSON.parse(workflowData)

                if workflowJson.get("result") = "success" then
                    set collaborators = JSON.parse(workflowJson.get("data"))

                    for i = 0 to len(collaborators)
                        collaboratorId = collaborators.get(i)

                        ' thanks json2
                        if collaboratorId <> "" then
                            getCoAuthors = getCoAuthors & "," & collaborators.get(i)
                        end if
                    next
                end if

            end if
        end if

        rec.close
        set rec = Nothing
    end if
end function
%>