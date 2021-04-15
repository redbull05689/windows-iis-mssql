<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
server.scriptTimeout = 10000
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
If Not(session("hasAccordInt") And session("regRoleNumber") <= 15) Then
	response.redirect("logout.asp")
End If
%>

<%
molId = request.querystring("id")
Call getconnected
Call getconnectedJchemReg
strQuery = "SELECT id,structure,notebookId FROM accMols WHERE id="&SQLClean(molId,"N","S")
Set rec = server.CreateObject("ADODB.RecordSet")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof then
	response.contenttype="text/plain"
	response.addheader "ContentType","text/plain"
	response.addheader "Content-Disposition", "inline; " & "filename="&rec("id")&"-mol.cdxml"
	response.write(rec("structure"))
End if
Call disconnect
Call disconnectJchemReg
%>