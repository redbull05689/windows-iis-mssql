<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
stripFontStylesFromTemplates = checkBoolSettingForCompany("disableFontsInCKTemplates", session("companyId"))
sectionId = "prep-templates-bio-protocol"
subsectionId = "prep-templates-bio-protocol"
%>
<!-- #include file="../_inclds/globals.asp"-->

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	

<%
If session("roleNumber") > 1 And Not session("canEditTemplates") Then
	response.redirect(mainAppPath&"/static/error.asp")
End if
%>
<%
templateId = request.querystring("id")
If (session("roleNumber") <= 1 Or session("canEditTemplates")) And (templateId <> "" Or request.Form("submit") <> "" )Then
	Call getconnected
	Set rec=server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT name, html FROM prepTemplatesBioProtocol WHERE id="&SQLClean(templateId,"N","S")& " AND companyId="&SQLClean(session("companyId"),"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		html = rec("html")
		name = rec("name")
		templateName = name
		canView = true
	End If
	Call disconnect
End if
%>

<%
If request.Form("submit")<>"" Then
	Call getconnectedAdm
	html = request.Form("html")
	name = request.Form("name")
	If name = "" Then
		errorString = "You must enter a name."
	Else
		If Trim(name) <> Trim(templateName) then
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT id from prepTemplatesBioProtocol WHERE name="&SQLClean(Trim(name),"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
			rec.open strQuery,connAdm,3,3
			If Not rec.eof Then
				errorString = "A template with this name already exists."
			End If
		End if
	End If
	If errorString = "" Then
		strQuery = "UPDATE prepTemplatesBioProtocol set name="&SQLClean(Trim(name),"T","S") &", html="&SQLClean(Replace(html,vbcrlf,""),"T","S")& " WHERE id="&SQLClean(request.querystring("id"),"N","S")& " AND companyId="&SQLClean(session("companyId"),"N","S")
		connAdm.execute(strQuery)
		Call disconnectAdm
		response.redirect("prepTemplates-bio-protocol.asp")
	End if
	Call disconnectAdm
End if
%>


<%
If canView then
%>

<h1>Edit Biology Protocol Template</h1>
<br/>
<form action="edit-prepTemplate-bio-protocol.asp?id=<%=templateId%>" method="post">
<table>
<%If errorString <> "" then%>
<tr style="margin-bottom:10px;">
	<td>
		<span style="color:red;font-weight:bold;"><%=errorString%></span>
	</td>
</tr>
<%End if%>
<tr>
	<td>
		<table style="margin-bottom:10px;">
			<tr>
				<td style="padding-right:10px;">
					<strong>Template Name:</strong>
				</td>
				<td>
					<input type="text" name="name" id="name" value="<%=name%>"/>
				</td>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td>
		<textarea cols="60" name="html" id="html" style="width:100%!imporant;padding-right:none;"><%=html%></textarea>
		<script type="text/javascript">
			<%
			If stripFontStylesFromTemplates Then
				ckEditorACFsetting = "disallowedContent:'*{font*}'"
			Else
				ckEditorACFsetting = "allowedContent:true"
			End If
			%>
			CKEDITOR.replace('html',{<%=ckEditorACFsetting%>,toolbar : 'arxspanToolbarPrepTemplatesAdmin',extraPlugins:'arx_onchange,arx_autoText,ajax,arx_templateCustomDropDowns'});
			CKEDITOR.instances.e_preparation.on('change',function(e){unsavedChanges=true;})
		</script>
	</td>
</tr>
<tr>
	<td align="right" style="padding-top:4px;">
		<input type="submit" name="submit" value="Save" style="float:right;margin-right:4px;padding:2px;width:60px;">
	</td>
</tr>
</table>
</form>
<%else%>
<p>Not Authorized</p>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%Call disconnect%>