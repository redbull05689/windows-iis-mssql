<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/security/functions/fnc_checkCoAuthors.asp"-->
<%
'remove note from experiment
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
notebookId = getNotebookId(experimentId,experimentType)

isCollaborator = False
If experimentType = 5 Then
	isCollaborator = checkCoAuthors(experimentId, experimentType,"new-note")
End If

noteId = request.querystring("noteId")
response.write(notebookId)

'only the experiment owner or collaborator of a custom experiment can remove a note
If ownsExperiment(experimentType,experimentId,session("userId")) or isCollaborator then

	Call getconnectedadm

	If request.querystring("pre") <> "" Then 'set presave flag
		pre = "1"
	Else
		pre = "0"
	End If
	
	'insert note into itemsToRemove table. notes will be hidden and will be deleted when the experiment is saved
	strQuery = "INSERT INTO itemsToRemove(experimentType,experimentId,itemType,itemId,pre) values(" &_
				SQLClean(experimentType,"N","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean("note","T","S") & "," &_
				SQLClean(noteId,"N","S") & "," &_
				SQLClean(pre,"N","S") & ")"

	connAdm.execute(strQuery)
End if
%>