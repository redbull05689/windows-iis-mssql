<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm
experimentId = Request.Form("experimentId")
experimentType = Request.Form("experimentType")
tagText = Request.Form("tagText")

If experimentId <> "" And experimentType <> "" And tagText <> "" Then
	If canViewExperiment(experimentType,experimentId,session("userId")) Then
		Call getConnected
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM experimentComments WHERE experimentType=" & SQLClean(experimentType,"N","S") & " AND experimentId=" & SQLClean(experimentId,"N","S") & " AND comment LIKE "&SQLClean(tagText,"T","S")
		rec.open strQuery,conn,3,3
		If Not rec.eof Then
			errorString = "This keyword already exists."
		Else
			strQuery = "INSERT into experimentComments(experimentType,experimentId,userId,comment,dateSubmitted,dateSubmittedServer) values(" &_
			SQLClean(experimentType,"N","S") & "," &_
			SQLClean(experimentId,"N","S") & "," &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(tagText,"T","S") & ",GETUTCDATE(),GETDATE());"
			connAdm.execute(strQuery)
		End If
		Call disconnect
		a = logAction(0,0,"",30)	
	End If
End if
Call disconnectAdm
%>