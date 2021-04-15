<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
subsectionId = "mappingTemplates"
'QQQ H3 Not allowed to delete
'deleteAllowed = False
deleteAllowed = true
%>
<!-- #include file="../_inclds/globals.asp"-->

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<%
If session("regRegistrar") Then
	canView = true
End if
If canView then
%>

<h1><%=mappingTemplatesLabel%></h1>
<br/>
<table class="experimentsTable" style="width:250px;">
<%
Call getConnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM mappingTemplates WHERE userId="&SQLClean(session("userId"),"N","S")&" ORDER BY templateName ASC"
rec.open strQuery,jchemRegConn,3,3
If rec.eof Then
	%>
	<tr><td>No Templates</td></tr>
	<%
Else
	%>
	<tr><th style="height:14px;">Template Name</th><%If deleteAllowed then%><th style="height:14px;"></th><%End if%></tr>
	<%
End if
Do While Not rec.eof
%>
<tr>
	<td>
		<%=rec("templateName")%>
	</td>
	<%If deleteAllowed then%>
	<td style="width:20px;" align="center">
		<a href="mappingTemplatesDelete.asp?templateId=<%=rec("id")%>" onclick="return confirm('Are you sure you want to delete this template?')"><img src="<%=mainAppPath%>/images/delete.png" class="png" border="0"></a>
	</td>
	<%End if%>
</tr>
<%
	rec.movenext
loop
%>
</table>
<%else%>
<p>Not Authorized</p>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%Call disconnect%>