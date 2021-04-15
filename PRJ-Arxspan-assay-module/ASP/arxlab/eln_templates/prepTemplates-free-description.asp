<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "prep-templates-free-description"
subsectionId = "prep-templates-free-description"
%>
<!-- #include file="../_inclds/globals.asp"-->

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<%
If session("roleNumber") <= 1 Or session("canEditTemplates") Then
	canView = true
End if
If canView then
%>

<h1>Concept Description Templates</h1>
<br/>
<a href="new-prepTemplate-free-description.asp">New Template</a>
<br/><br/>
<table class="experimentsTable" style="width:250px;">
<%
Call getConnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT name, id FROM prepTemplatesfreeDescription WHERE companyId="&SQLClean(session("companyId"),"N","S")&" ORDER BY name ASC"
rec.open strQuery,conn,3,3
If rec.eof Then
	%>
	<tr><td>No Templates</td></tr>
	<%
Else
	%>
	<tr><th style="height:14px;">Template Name</th><th style="height:14px;"></th><th style="height:14px;"></th></tr>
	<%
End if
Do While Not rec.eof
%>
<tr>
	<td>
		<%=rec("name")%>
	</td>
	<td style="width:20px;" align="center">
		<a href="edit-prepTemplate-free-description.asp?id=<%=rec("id")%>"><img src="<%=mainAppPath%>/images/btn_edit.gif" border="0"></a>		
	</td>
	<td style="width:20px;" align="center">
		<a href="delete-prepTemplate-free-description.asp?id=<%=rec("id")%>" onclick="return confirm('Are you sure you want to delete this template?')"><img src="<%=mainAppPath%>/images/delete.png" class="png" border="0"></a>
	</td>
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