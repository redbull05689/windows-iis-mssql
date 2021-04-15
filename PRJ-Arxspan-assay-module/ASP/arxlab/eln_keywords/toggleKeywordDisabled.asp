<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
if session("canEditKeywords") or session("role") = "Admin" Then
	Dim checkboxStatus
	if request.Form("checkboxStatus") = "true" Then
		checkboxStatus = 1
	Elseif request.Form("checkboxStatus") = "false" Then
		checkboxStatus = 0
	End If

	Call getconnectedAdm
	strQuery = "UPDATE keywords SET disabled=" & SQLClean(checkboxStatus,"N","S") & " WHERE id=" & SQLClean(request.Form("keywordId"),"N","S") & " AND companyId=" & SQLClean(session("companyId"),"N","S")

	connAdm.execute(strQuery)
	Call disconnectAdm
End if
%>