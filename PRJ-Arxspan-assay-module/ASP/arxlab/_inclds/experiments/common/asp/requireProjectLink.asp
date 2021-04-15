<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
	hasLink = False
	Set lRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM linksProjectExperimentsView WHERE experimentId="&SQLClean(experimentId,"N","S")& " AND typeId="&SQLClean(experimentType,"N","S")
	lRec.open strQuery,conn
	If Not lRec.eof then
		hasLink = True
	End If
	lRec.close

	If Not hasLink Then
		strQuery = "SELECT id FROM linksProjectNotebooksView WHERE notebookId="&SQLClean(notebookId,"N","S")
		lRec.open strQuery,conn
		if Not lRec.eof then
			hasLink = True
		End if
		lRec.close
	End If
	
	If Not hasLink Then
		response.write("<div id='resultsDiv'>Project link is required.  Please link experiment to a project.</div>")
		response.end
	End if
	
	Set lRec = nothing
%>