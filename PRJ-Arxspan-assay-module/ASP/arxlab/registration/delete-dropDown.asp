<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("regRegistrar") And Not session("regRegistrarRestricted") Then
	Call getconnectedJchemReg
	Set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT * FROM regDropDowns WHERE id="&SQLClean(request.querystring("id"),"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof then
		strQuery = "DELETE FROM regDropDowns WHERE id="&SQLClean(request.querystring("id"),"N","S")
		jchemRegConn.execute(strQuery)
		strQuery = "DELETE FROM regDropDownOptions WHERE parentId="&SQLClean(request.querystring("id"),"N","S")
		jchemRegConn.execute(strQuery)
	End If
	rec.close
	Set rec = nothing
	Call disconnectJchemReg
End If
response.redirect("customDropDowns.asp")
%>