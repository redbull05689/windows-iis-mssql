<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("regRegistrar") And Not session("regRegistrarRestricted") Then
	Call getconnectedJchemReg
	strQuery = "delete from comboCustomFields WHERE id="&SQLClean(request.querystring("id"),"N","S")
	jchemRegConn.execute(strQuery)
	strQuery = "delete from comboCustomFieldFields WHERE groupId="&SQLClean(request.querystring("id"),"N","S")
	jchemRegConn.execute(strQuery)
	Call disconnectJchemReg
End If
response.redirect("comboCustomFields.asp")
%>