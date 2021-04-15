<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("roleNumber") <= 1 Or session("canEditTemplates") Then
	Call getconnectedAdm
	strQuery = "DELETE FROM prepTemplatesBioSummary WHERE id="&SQLClean(request.querystring("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
	connAdm.execute(strQuery)
	Call disconnectAdm
End If
response.redirect("prepTemplates-bio-summary.asp")
%>