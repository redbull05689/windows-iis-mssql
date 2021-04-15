<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getReadNotebooks(userId)
	'get all notebooks that the specified user can has view access to
	notebookString = ""
	notebookCount = 0
	
	Set grnRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "select distinct notebookId FROM allNotebookPermViewWithInfo WHERE canRead=1 and userId="&SQLClean(userId,"N","S")&" and visible=1 and (accepted=1 or accepted is null)"
	grnRec.open strQuery,conn,3,3
	'loop through all the notebooks in the allnotebookpermview
	Do While Not grnRec.eof
		notebookCount = notebookCount + 1
		notebookString = notebookString & grnRec("notebookId") & ","
		grnRec.movenext
	Loop
	grnRec.close
	
	strQuery = "select distinct notebookId FROM projectNotebookPermView WHERE canRead=1 AND shareeId="&SQLClean(userId,"N","S")&" AND (accepted=1 OR accepted is NULL)"
	grnRec.open strQuery,conn,3,3
	'loop through all the notebooks in the allnotebookpermview
	Do While Not grnRec.eof
		notebookCount = notebookCount + 1
		notebookString = notebookString & grnRec("notebookId") & ","
		grnRec.movenext
	Loop
	grnRec.close
	Set grnRec = Nothing
	
	'if admin then add all notebooks at the company
	'this is wrong it breaks the userId parameter
	If session("roleNumber") = 1 then
		Set grnRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "select notebookId FROM notebookIndexView WHERE companyId="&SQLClean(session("companyId"),"N","S")
		grnRec.open strQuery,conn,3,3
		'loop through all the notebooks in the allnotebookpermview
		Do While Not grnRec.eof
			notebookCount = notebookCount + 1
			notebookString = notebookString & grnRec("notebookId") & ","
			grnRec.movenext
		Loop
		grnRec.close
		Set grnRec = nothing
	End if
	
	'remove the trailing comma if the string is not empty
	If notebookCount >= 1 Then
		notebookString = Mid(notebookString,1,Len(notebookString)-1)
	End If

	If notebookString = "" Then
		getReadNotebooks ="0"
	Else
		'return the list of read notebooks 'nxq is this list complete?
		getReadNotebooks = removeDuplicates(notebookString)
	End if
end function
%>