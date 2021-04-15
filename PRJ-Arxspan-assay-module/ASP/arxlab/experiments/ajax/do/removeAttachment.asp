<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
'remove an attachment from an experiment
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
notebookId = getNotebookId(experimentId,experimentType)
attachmentId = request.querystring("attachmentId")
response.write(notebookId)
canRemove = True
'do not allow removal if the user/company is collaboration experiments only and the user
'does not have can delete privleges
If session("hasMUFExperiment") and session("hideNonCollabExperiments") And Not session("canDelete") Then
	canRemove = False
End If

'can only remove attachment if user owns experiment
If (ownsExperiment(experimentType,experimentId,session("userId")) or checkCoAuthors(experimentId, experimentType, "")) And canRemove then
	Call getconnectedadm
	If request.querystring("pre") <> "" Then ' set presave flag
		pre = "1"
	Else
		pre = "0"
	End If
	'insert attachments into itemsToRemove table. Attachments will be hidden and will be deleted when the experiment is saved
	strQuery = "INSERT INTO itemsToRemove(experimentType,experimentId,itemType,itemId,pre) values(" &_
				SQLClean(experimentType,"N","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean("attachment","T","S") & "," &_
				SQLClean(attachmentId,"N","S") & "," &_
				SQLClean(pre,"N","S") & ")"

	connAdm.execute(strQuery)

	'collaboration experiment
	If session("hasMUFExperiment") And experimentType="3" Then
		'on removal of an attachment from a collaboration experiment
		'send a notification to all users that can view an experiment that an 
		'attachment has been removed
		Set recN = server.CreateObject("ADODB.RecordSet")
		
		'select correct table
		If pre=1 Then 
			strQuery = "SELECT filename FROM freeAttachments_preSave WHERE id="&SQLClean(attachmentId,"N","S")
		Else
			strQuery = "SELECT filename FROM freeAttachments WHERE id="&SQLClean(attachmentId,"N","S")
		End If
		recN.open strQuery,conn,0,-1
		If Not recN.eof Then
			'get filename
			fileLabel = recN("filename")
		End If
		recN.close
		Set recN = Nothing
		
		'build link tp experiment
		Set recN = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT typeId, experimentId, name FROM notebookIndexView WHERE typeId="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")
		recN.open strQuery,conn,0,-1
			If recN("typeId") = 1 then
				theLink = "<a href="""&mainAppPath&"/"&session("expPage")&"?id="&Trim(recN("experimentId"))&""">"&recN("name")&"</a>"
			End if
			If recN("typeId") = 2 then
				theLink = "<a href="""&mainAppPath&"/bio-experiment.asp?id="&Trim(recN("experimentId"))&""">"&recN("name")&"</a>"
			End If
			If recN("typeId") = 3 then
				theLink = "<a href="""&mainAppPath&"/free-experiment.asp?id="&Trim(recN("experimentId"))&""">"&recN("name")&"</a>"
			End If
			If recN("typeId") = 4 then
				theLink = "<a href="""&mainAppPath&"/anal-experiment.asp?id="&Trim(recN("experimentId"))&""">"&recN("name")&"</a>"
			End If
		title = "Attachment Removed"
		message = "User "&session("firstName")&" "&session("lastName")&" has removed a file """&fileLabel&""" from "&theLink

		'send notification to all users who can view the experiment
		a = usersWhoCanViewExperiment(experimentType,experimentId)
		users = Split(a,",")
		For q = 0 To ubound(users)
			If CStr(users(q)) <> CStr(session("userId")) then
				a = sendNotification(users(q),title,message,14)
			End if
		Next
		recN.close
		Set recN = nothing
	End if
End if
%>