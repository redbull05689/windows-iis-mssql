<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function getNextExperimentNumber(notebookId, keepNumber)
	getNextExperimentNumber = -1
	
	If notebookId <> "" Then
		'default the experiment count to 
		experimentCount = 1

		Call getconnected
		Set nextRec = server.CreateObject("ADODB.RecordSet")
		foundPagesCreated = True
		strQuery = "SELECT pagesCreated as recordCount FROM notebookPageCounts WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND notebookId="&SQLClean(notebookId,"N","S")
		nextRec.open strQuery,conn,3,3
		
		If nextRec.eof Then
			nextRec.close
			foundPagesCreated = False
			strQuery = "SELECT count(*) as recordCount FROM notebookIndex WHERE notebookId="&SQLClean(notebookId,"N","S")
			nextRec.open strQuery,conn,3,3
		End If
		
		If Not nextRec.eof Then
			experimentCount = CInt(nextRec("recordCount")) + 1
			getNextExperimentNumber = experimentCount
			nextRec.close
		End if
		
		strQuery = ""
		Set nextRec = Nothing
		'add preceding zeros to experiment count
		experimentCount = CInt(experimentCount)

		If keepNumber Then
			If Not foundPagesCreated Then
				strQuery = "INSERT INTO notebookPageCounts (companyId, notebookId, pagesCreated) VALUES (" & SQLClean(session("companyId"),"N","S") & "," & SQLClean(notebookId,"N","S") & "," & SQLClean(experimentCount,"N","S") & ")"
			Else
				strQuery = "UPDATE notebookPageCounts SET pagesCreated=" & SQLClean(experimentCount,"N","S") & " WHERE companyId=" & SQLClean(session("companyId"),"N","S") & " AND notebookId=" & SQLClean(notebookId,"N","S")
			End If
		
			connAdm.execute(strQuery)
		End If

		Call disconnect
	End If
End Function

Function getNextExperimentName(notebookId)
	'return the next experiment name for the supplied notebook. form = [notebook_name] - [experiment number]
	call getconnected
	Set neRec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT name from notebooks WHERE id="&SQLClean(notebookId,"N","S")
	neRec2.open strQuery,conn,3,3
	If Not neRec2.eof Then
		'if there are no experiments then set the experiment name string to the notebook name
		gnExperimentName = Replace(neRec2("name"),"''","")
	End If
	neRec2.close
	Set neRec2 = Nothing

	experimentCount = CStr(getNextExperimentNumber(notebookId, True))
	If experimentCount < 10 Then
		experimentCount = "00" + CStr(experimentCount)
	Else
		If experimentCount < 100 Then
			experimentCount = "0" + CStr(experimentCount)
		Else
			If experimentCount < 1000 Then
				experimentCount = CStr(experimentCount)
			End if
		End if
	End If
		
	'make/return name string
	getNextExperimentName = gnExperimentName & " - " & experimentCount
End function
%>