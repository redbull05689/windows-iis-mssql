<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getManagerNotebooks(userId)
	'get all the notebookIds that a manager has created or any member of his team has created
	notebookString = ""
	notebookCount = 0

	'notebook ids where the notebook is created by the userid or any user who was added by the user id
	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	Set grnRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "select id from notebooks WHERE (userId="&SQLClean(userId,"N","S")&" or userId in (SELECT id from "&usersTable&" WHERE userAdded="&SQLClean(userId,"N","S")&")) AND visible=1"
	grnRec.open strQuery,conn,3,3
	'loop through all the notebooks and add id to string
	Do While Not grnRec.eof
		notebookCount = notebookCount + 1
		notebookString = notebookString & grnRec("id") & ","
		grnRec.movenext
	Loop
	grnRec.close
	'if there is more than one notebook then remove the trailing comma
	If notebookCount >= 1 Then
		notebookString = Mid(notebookString,1,Len(notebookString)-1)
	End If
	Set grnRec = Nothing
	If notebookString = "" Then
		'return zero if there are no notebooks
		getManagerNotebooks ="0"
	Else
		'set function value as the list of notebooks string
		getManagerNotebooks = notebookString
	End if
end function
%>