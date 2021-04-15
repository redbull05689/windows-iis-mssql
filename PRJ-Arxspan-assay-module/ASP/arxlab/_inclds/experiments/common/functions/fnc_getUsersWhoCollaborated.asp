<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getUsersWhoCollaborated(experimentId, experimentType)
	getUsersWhoCollaborated = ""

    if experimentType = "5" then
        
        strQuery = "SELECT DISTINCT r.userId FROM custExperiments_history e " &_
                   "LEFT JOIN [ARXSPAN-ORDERS-" & whichServer & "].dbo.requestHistory r " &_
                   "ON e.requestRevisionNumber=r.id " &_
                   "WHERE e.experimentId=" & experimentId & " " &_
                   "AND r.userId is not null " &_
                   "AND e.revisionNumber <> 1" 
        'Filtering out revision number 1 from the ELN should be safe: that is either going to be the original
        'author, or the user who made the experiment this one was copied from, who shouldn't be counted anyway
        'unless they're added in as a collaborator, which is already accounted for.
	    Set rec = server.CreateObject("ADODB.RecordSet")
        
        rec.open strQuery, connAdm, 3, 3
        Do While not rec.eof
            if getUsersWhoCollaborated = "" then
                getUsersWhoCollaborated = rec("userId")
            else
                getUsersWhoCollaborated = getUsersWhoCollaborated & "," & rec("userId")
            end if
            rec.moveNext
        loop
    end if
end function
%>