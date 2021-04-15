<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
whiteListOverride = true
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
numFields = request.querystring("numFields")
templateName = request.querystring("templateName")
success = false
Call getconnectedjchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from mappingTemplates WHERE userId="&SQLClean(session("userId"),"N","S")&" AND templateName="&SQLClean(templateName,"T","S")
rec.open strQuery,jchemRegConn,3,3
If rec.eof Then
	strQuery = "INSERT into mappingTemplates(templateName,userId) values("&SQLClean(templateName,"T","S")&","&SQLClean(session("userId"),"N","S")&")"
	jchemRegConn.execute(strQuery)
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * from mappingTemplates WHERE userId="&SQLClean(session("userId"),"N","S")&" AND templateName="&SQLClean(templateName,"T","S")
	rec2.open strQuery,jchemRegConn,3,3
	newId = rec2("id")
	For i = 1 To numFields
		strQuery = "INSERT into mappingTemplateOptions(sdName,fieldName,defaultExists,defaultValue,appendData,templateId) values("&_
		SQLClean(request.querystring("sdName_"&i),"T","S")&","&_
		SQLClean(request.querystring("regName_"&i),"T","S")&","&_
		SQLClean(request.querystring("hasDefault_"&i),"N","S")&","&_
		SQLClean(request.querystring("defaultValue_"&i),"T","S")&","&_
		SQLClean(request.querystring("appendData_"&i),"N","S")&","&_
		SQLClean(newId,"N","S")&")"
		jchemRegConn.execute(strQuery)
	Next
	success = true
Else
	response.write("A template with that name already exists")
End If
rec.close
Set rec = nothing
Call disconnectJchemReg
If success Then
	response.write("success")
End if
%>
