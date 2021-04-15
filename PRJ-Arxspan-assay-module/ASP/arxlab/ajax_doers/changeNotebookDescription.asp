<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'changes notebook description

id = request.querystring("id")
description = request.querystring("data")
encodedDesc = Server.HTMLEncode(description)

'only the notebook owner can change the description
If ownsNotebook(id) Then
	Call getconnectedAdm
	'change the notebook description
	strQuery = "UPDATE notebooks SET description="&SQLClean(encodedDesc,"T","S")&" WHERE id="&SQLClean(id,"N","S")
	connAdm.execute(strQuery)
	Call disconnectadm
	response.write("success")
Else
	'return permission error
	response.write("An error occurred changing notebook description.")
End If
%>