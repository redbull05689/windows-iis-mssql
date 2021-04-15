<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("roleNumber") <= 1 Or session("canEditTemplates") Then
	Call getconnectedAdm
	Set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT id FROM templateDropDowns WHERE id="&SQLClean(request.querystring("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
	rec.open strQuery,connAdm,3,3
	If Not rec.eof then
		strQuery = "DELETE FROM templateDropDowns WHERE id="&SQLClean(request.querystring("id"),"N","S") & " AND companyId="&SQLClean(session("companyId"),"N","S")
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM templateDropDownOptions WHERE parentId="&SQLClean(request.querystring("id"),"N","S")
		connAdm.execute(strQuery)
	End If
	rec.close
	Set rec = nothing
	Call disconnectAdm
End If
response.redirect("customDropDowns.asp")
%>