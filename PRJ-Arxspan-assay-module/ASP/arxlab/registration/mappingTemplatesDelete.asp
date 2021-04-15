<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
templateId = request.querystring("templateId")

Call getconnectedjchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from mappingTemplates WHERE userId="&SQLClean(session("userId"),"N","S")&" AND id="&SQLClean(templateId,"N","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	strQuery = "DELETE FROM mappingTemplateOptions WHERE templateId="&SQLClean(templateId,"N","S")
	jchemRegConn.execute(strQuery)
	strQuery = "DELETE FROM mappingTemplates WHERE id="&SQLClean(templateId,"N","S")
	jchemRegConn.execute(strQuery)
End If
rec.close
Set rec = nothing
Call disconnectJchemReg
response.redirect("mappingTemplates.asp")
%>
