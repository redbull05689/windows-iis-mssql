<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("regRegistrar") And Not session("regRegistrarRestricted") Then
	Call getconnectedJchemReg
	strQuery = "UPDATE groupCustomFields set visible=0 WHERE id="&SQLClean(request.querystring("id"),"N","S")
	jchemRegConn.execute(strQuery)
	Call disconnectJchemReg
End If
response.redirect("groupCustomFields.asp")
%>