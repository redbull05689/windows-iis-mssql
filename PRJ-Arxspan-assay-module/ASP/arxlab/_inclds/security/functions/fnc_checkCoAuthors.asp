<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function checkCoAuthors(experimentId, experimentType, callingMethod)
	'returns true if the user is a coauthor of the experiment
	' assume false
	checkCoAuthors = False
    if experimentType = "5" then
        strQuery = "SELECT requestId " &_
                    "FROM custExperiments " &_
                    "WHERE id=" & experimentId
        Set coAuthRec = server.CreateObject("ADODB.RecordSet")
        coAuthRec.open strQuery, connadm, 3, 3
        
        if not coAuthRec.eof then
            reqId = coAuthRec("requestId")
            session("reqId") = reqId
                    
            if reqId <> "" then
                ' Make a workflow request with the request Id and request revision, then get right to the information we want.
                coAuthUrl = "/requests/{requestId}/checkCollaborator/?appName=ELN"
                coAuthUrl = Replace(coAuthUrl, "{requestId}", reqId)
                
                set workflowData = JSON.parse(appServiceGet(coAuthUrl))
                checkCoAuthors = workflowData.get("isCollaborator") = true
            end if
        end if
        coAuthRec.close
        Set coAuthRec = Nothing
    end if
End Function
%>