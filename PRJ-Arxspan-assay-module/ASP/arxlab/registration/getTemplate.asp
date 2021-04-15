<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
On Error Resume next
Call getconnected

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM regTemplates WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND groupId="&SQLClean(request.querystring("groupId"),"N","S")
If request.querystring("addBatch") = "1" Then
	strQuery = strQuery & " AND batch=1"
else
	strQuery = strQuery & " AND compound=1"
End If
rec.open strQuery,conn,3,3
If Not rec.eof Then
	regTemplatePath = getCompanySpecificSingleAppConfigSetting("regTemplatePath", session("companyId"))
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	Set TextStream = fs.OpenTextFile(regTemplatePath&"\"&rec("filename"), 1, False, -2)
	html = TextStream.ReadAll
	TextStream.close
	Set TextStream = nothing
	response.write(html)
End if

Call disconnect
On Error goto 0
%>