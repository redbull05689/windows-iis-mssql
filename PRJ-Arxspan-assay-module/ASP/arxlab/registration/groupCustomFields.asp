<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->

<%
sectionId = "reg"
subSectionId = "group-custom-fields"
if Not session("regRegistrar") Or session("regRegistrarRestricted") Then
	response.redirect("logout.asp")
End If
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<%
If session("regRegistrar") And Not session("regRegistrarRestricted") And session("hasGroupFields") Then
	canView = true
End if
If canView then
%>

<div class="registrationPage">
<h1><%=groupCustomFieldsLabel%></h1>
<br/>

<a href="new-fieldGroup.asp">New Field Group</a>
<br/><br/>
<table class="experimentsTable" style="width:250px;">
<%
Call getConnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM groupCustomFields WHERE visible<>0 ORDER BY name ASC"
rec.open strQuery,jchemRegConn,3,3
If rec.eof Then
	%>
	<tr><td>No Group Fields</td></tr>
	<%
Else
	%>
	<tr><th style="height:14px;">Field Group Name</th><th style="height:14px;"></th><th style="height:14px;"></th></tr>
	<%
End if
Do While Not rec.eof
%>
<tr>
	<td>
		<%=rec("name")%>
	</td>
	<td style="width:20px;" align="center">
		<a href="customFields.asp?groupId=<%=rec("id")%>"><img src="<%=mainAppPath%>/images/btn_edit.gif" border="0" style="border:none;"></a>		
	</td>
	<td style="width:20px;" align="center">
		<a href="delete-groupFields.asp?id=<%=rec("id")%>" onclick="return confirm('Are you sure you want to delete this group?')"><img src="<%=mainAppPath%>/images/delete.png" class="png" border="0" style="border:none;"></a>
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
</div>

<!-- #include file="../_inclds/footer-tool.asp"-->
<%Call disconnectJchemReg%>