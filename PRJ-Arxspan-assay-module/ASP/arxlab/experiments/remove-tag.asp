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
		If session("role") = "Admin" Then
			strQuery = "DELETE FROM experimentComments WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")&" AND comment LIKE "&SQLClean(tagText,"T","S")
			Set rs = connAdm.execute(strQuery)
		Else
			strQuery = "DELETE FROM experimentComments WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")&" AND comment LIKE "&SQLClean(tagText,"T","S")&" AND userId="&SQLClean(session("userId"),"T","S")
			Set rs = connAdm.execute(strQuery)
		End If
	End If
End if
Call disconnectAdm
%>