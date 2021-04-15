<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("companyId") = "1" And session("email") = "support@arxspan.com" Then
	'create the default set of preparation templates and preparation template drop downs for the specified company

	toCompanyId=100
	fromCompanyId=1
	Call getconnectedadm
	'delete everything from the prep templates and template drop down/drop down options table for the company id
	strQuery = "DELETE FROM prepTemplates WHERE companyId="&SQLClean(toCompanyId,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE FROM templateDropDownOptions WHERE parentId in (SELECT id from templateDropDowns WHERE companyId="&SQLClean(toCompanyId,"N","S")&")"
	connAdm.execute(strQuery)
	strQuery = "DELETE FROM templateDropDowns WHERE companyId="&SQLClean(toCompanyId,"N","S")
	connAdm.execute(strQuery)


	'copy all the prep templates from arxspan to the new company
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM prepTemplates WHERE companyId="&SQLClean(fromCompanyId,"N","S")
	rec.open strQuery,connAdm,3,3
	Do While Not rec.eof
		strQuery = "INSERT INTO prepTemplates(companyId,userId,name,html,isGroup) values(" &_
			SQLClean(toCompanyId,"N","S") & "," &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(rec("name"),"T","S") & "," &_
			SQLClean(rec("html"),"T","S") & "," &_
			SQLClean(rec("isGroup"),"N","S") & ")"
		connAdm.execute(strQuery)
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing


	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM templateDropDowns WHERE companyId="&SQLClean(fromCompanyId,"N","S")
	rec.open strQuery,connAdm,3,3
	'loop through all the template dropdowns from fromCompanyId
	Do While Not rec.eof
				'insert the template drop down for the new company
				strQuery = "INSERT INTO templateDropDowns(name,heading,companyId) output inserted.id as newId values("&SQLClean(rec("name"),"T","S")&","&SQLClean(rec("heading"),"T","S")&","&SQLClean(toCompanyId,"N","S")&")"
				Set rs = connAdm.execute(strQuery)
				'get the id of the template drop down so that the options have the template drop down id for their partent id
				newId = CStr(rs("newId"))

				'insert all the options from toCompanyId with the companies parent id for the template drop down
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM templateDropDownOptions WHERE parentId="&SQLClean(rec("id"),"N","S")
				rec2.open strQuery,connAdm,3,3
				Do While Not rec2.eof
					strQuery = "INSERT INTO templateDropDownOptions(parentId,value) values("&SQLClean(newId,"N","S")&","&SQLClean(rec2("value"),"T","S")&")"
					connAdm.execute(strQuery)
					rec2.movenext
				Loop
				rec2.close
				Set rec2 = nothing
		rec.movenext
	Loop
	rec.close
	Set rec = nothing
	response.write("succeeded")
Else
	response.write("failed")
End If
response.end()
%>