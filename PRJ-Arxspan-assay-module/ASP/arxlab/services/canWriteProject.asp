<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage=True%>
<%
response.charset = "UTF-8"
response.codePage = 65001
userId = request.querystring("userId")
projectId = request.querystring("projectId")
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
If canWriteProject(projectId,userId) Then
	response.write("true")
Else
	response.write("false")
End if
%>