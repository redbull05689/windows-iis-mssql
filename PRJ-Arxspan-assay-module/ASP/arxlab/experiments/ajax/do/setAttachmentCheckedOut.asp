<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'412015%>
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/security/functions/fnc_checkCoAuthors.asp"-->
<%
'set checked out flag for attachment in attachment table
attachmentId = request.querystring("attachmentId")
state = request.querystring("state")
experimentType = request.querystring("experimentType")
attachmentTable=""

'get the right table based on experiment type
prefix = GetPrefix(experimentType)
attachmentTable = GetFullName(prefix, "attachments", true)
Call getconnected
Call getconnectedadm

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT experimentId FROM "&attachmentTable&" WHERE id="&SQLClean(attachmentId,"N","S")
rec.open strQuery,conn,0,-1
'make sure attachment exists
If Not rec.eof Then
	
	'update flag if the user owns the experiment or if they are a collaborator
	isCollaborator = False
	If experimentType = 5 Then
		isCollaborator = checkCoAuthors(rec("experimentId"), experimentType, "setAttachmentCheckedOut")
	End If

	If ownsExperiment(experimentType,rec("experimentId"),session("userId")) Or isCollaborator Then

		If experimentType = 5 Then
			If state = 1 Then			
				strQuery = "UPDATE "&attachmentTable&" SET checkedOut="&SQLClean(state,"N","S")&", checkedOutUser="&SQLClean(session("userId"),"N","S")&" WHERE id="&SQLClean(attachmentId,"N","S")
			Else
				strQuery = "UPDATE "&attachmentTable&" SET checkedOut="&SQLClean(state,"N","S")&", checkedOutUser=NULL WHERE id="&SQLClean(attachmentId,"N","S")
			End If
		Else 
			strQuery = "UPDATE "&attachmentTable&" SET checkedOut="&SQLClean(state,"N","S")&" WHERE id="&SQLClean(attachmentId,"N","S")
		End If
	
		connAdm.execute(strQuery)
	End if
End if

Call disconnect
Call disconnectadm
%>
<%'/412015%>