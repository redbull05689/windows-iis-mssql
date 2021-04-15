<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
stripFontStylesFromTemplates = checkBoolSettingForCompany("disableFontsInCKTemplates", session("companyId"))
sectionId = "prep-templates"
subsectionId = "prep-templates"
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
If request.Form("submit")<>"" Then
	Call getconnectedAdm
	html = request.Form("html")
	name = request.Form("name")
	If request.Form("isGroup") = "on" Then
		isGroupDBVal = 1	
	Else
		isGroupDBVal = 0
	End if
	If name = "" Then
		errorString = "You must enter a name."
	Else
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id from prepTemplates WHERE name="&SQLClean(Trim(name),"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
		rec.open strQuery,connAdm,3,3
		If Not rec.eof Then
			errorString = "A template with this name already exists."
		End If
	End If
	If errorString = "" Then
		strQuery = "INSERT into prepTemplates(name,html,companyId,isGroup) values("&_
		SQLClean(Trim(name),"T","S") & "," &_
		SQLClean(Replace(html,vbcrlf,""),"T","S") & "," &_
		SQLClean(session("companyId"),"N","S") & "," &_
		SQLClean(isGroupDBVal,"N","S") & ")"
		connAdm.execute(strQuery)
		Call disconnectAdm
		response.redirect("prepTemplates.asp")
	End if
	Call disconnectAdm
End if
%>


<%
If session("roleNumber") <= 1 Or session("canEditTemplates") Then
	canView = true
End if
If canView then
%>

<h1>New Chemistry Preparation Template</h1>
<br/>
<form action="new-prepTemplate.asp" method="post">
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
					<input type="text" name="name" id="name"/>
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
			var cke_highest_group_id = 0
			CKEDITOR.replace('html',{<%=ckEditorACFsetting%>,toolbar : 'arxspanToolbarPrepTemplatesAdmin',extraPlugins:'arx_onchange,arx_autoText,ajax,arx_reactantDropDowns,arx_reagentDropDowns,arx_productDropDowns,arx_solventDropDowns,arx_templateCustomDropDowns,arx_groupedTemplateDropdown'});
			CKEDITOR.instances.e_preparation.on('change',function(e){unsavedChanges=true;})
		</script>
	</td>
</tr>
<tr>
	<td align="right">
		Is Group:&nbsp;<input type="checkbox" name="isGroup" style="display:inline;margin-right:10px;" <%If isGroup then%>checked<%End if%>>
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