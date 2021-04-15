<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
'adding the script timeout due to long copys only copying half of the experiment
'Note: this is a quick fix and should be fixed in later tickets: ,6069, 6070
Server.ScriptTimeout=1200
'this script is a non ajax script that creates an experiment.  This page takes querystring parameters and calls the appropriate functions
'to copy the experiment and then redirects the user to the appropriate page depending on how many copies they have made

'get querystring variables
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
revisionNumber = request.querystring("revisionNumber")
newNotebookId = request.querystring("newNotebookId")
numCopies = request.querystring("numCopies")
copyAttachments = request.querystring("copyAttachments") = "yes"
copyNotes = request.querystring("copyNotes") = "yes"

'default to one copy if the number of copies is not an integer
If Not isInteger(numCopies) Then
	numCopies = 1
Else
	numCopies = CInt(numCopies)
End If

'set the number of experiments to the closer end of the range if the
'requested number of copies is outside the 1 to 10 range
If numCopies < 1 Then numCopies = 1
If numCopies > 10 Then numCopies = 10

' 'If the user has crais do not allow an experiment to be copied unless it has
' 'passed the crais check
' If session("hasCrais") And experimentType="1" Then
' 	Call getconnected
' 	Set rec = server.CreateObject("ADODB.RecordSet")
' 	strQuery = "SELECT craisStatus FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
' 	rec.open strQuery,conn,0,-1
' 	If Not rec.eof Then
' 		If rec("craisStatus")=3 Or rec("craisStatus")=0 Then
' 			title = "General Error"
' 			message = "Experiment cannot be copied without passing regulatory check."
' 			response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
' 		End if
' 	End If
' 	rec.close
' 	Set rec = nothing
' End if

'an experiment can only be copied if the user has view access to the experiment being copied 
'and write access to the destination notebook
If canViewExperiment(experimentType,experimentId,session("userId")) And canWriteNotebook(newNotebookId) then
	Call getconnectedadm

	'loop once for each copy to be made
	For theVar = 1 To numCopies

		'copy all the experiment database data and get the new id
		newId = copyExperiment(experimentType,experimentId,revisionNumber,newNotebookId,copyAttachments,copyNotes)

		'add newly created notebook to the notebookIndex
		strQuery = "INSERT into notebookIndex(notebookId,experimentId,typeId) output inserted.id as newId values("&SQLClean(newNotebookId,"N","S")&","&SQLClean(newId,"N","S")&","&SQLClean(experimentType,"N","S")&")"
		Set rs = connAdm.execute(strQuery)
		newNotebookIndexId = CStr(rs("newId"))

		'select the row for the experiment to be copied
		Set nRec = server.CreateObject("ADODB.RecordSet")
		prefix = GetPrefix(experimentType)
		tableName = GetFullName(prefix, "experiments", true)
		strQuery = "SELECT id FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
		nRec.open strQuery,connAdm,3,3
		If Not nRec.eof Then
			'set the user id of the copied experiment from the initial user id to the user id of the user that copied it
			strQuery = "UPDATE notebookIndex SET userId="&SQLClean(session("userId"),"N","S")& " WHERE id="&SQLClean(newNotebookIndexId,"N","S")
			connAdm.execute(strQuery)
		End if

		Call getconnected
		If copyAttachments Then
			'copy the files from the uploads folder from the old experiment folder to the new experiment folder
			a = copyAttachmentFiles(experimentType,experimentId,newId,revisionNumber)
		End if
		
		Select Case experimentType
			Case "1"
				logActionId = 2
			Case "2"
				logActionId = 3
			Case "3"
				logActionId = 4
			Case "4"
				logActionId = 3
		End Select
	next	

	'make the latest updated notebook default
	usrTbl = getDefaultSingleAppConfigSetting("usersTable")
	If usrTbl <> "" Then
		nbuQuery = "UPDATE "&usrTbl&" SET defaultNotebookId="&SQLClean(newNotebookId,"N","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
		connAdm.execute(nbuQuery)
	End If
	session("defaultNotebookId") = SQLClean(newNotebookId,"N","S")
	
		
	If numCopies = 1 Then
		'if we are only making one copy of the experiment redirect the user to the newly created experiment
		prefix = GetPrefix(experimentType)
		page = GetExperimentPage(prefix)
		redirectPage = mainAppPath&"/"& page &"?id="&SQLClean(newId,"N","S")
	Else
		'if we are making multiple copies redirect the user to the destination notebook
		redirectPage = mainAppPath&"/show-notebook.asp?id="&newNotebookId
	End if
	a = logAction(logActionId,newId,"",13)
	response.redirect(redirectPage)

Else
'return not authorized error
%>
<p>You are not authorized to copy this experiment to this notebook</p>
<%
End if
%>