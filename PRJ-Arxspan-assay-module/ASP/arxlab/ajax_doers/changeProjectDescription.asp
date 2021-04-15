<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'change project description

id = request.querystring("id")
description = request.querystring("data")

'only the project owner can change the description
If ownsProject(id) Then
	Call getconnectedAdm
	'change the description
	strQuery = "UPDATE projects SET description="&SQLClean(description,"T","S")&" WHERE id="&SQLClean(id,"N","S")
	connAdm.execute(strQuery)
	Call disconnectadm
	response.write("success")
Else
	'return permission error
	response.write("An error occurred changing notebook description.")
End If
%>