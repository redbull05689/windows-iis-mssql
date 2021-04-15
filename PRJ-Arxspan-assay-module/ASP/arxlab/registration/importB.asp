<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
hideSmallMolecule = checkBoolSettingForCompany("hideSmallMolecule", session("companyId"))

sectionId = "reg"
subSectionId = "import2"
if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If
%>
<%
Set UploadProgress = Server.CreateObject("Persits.UploadProgress")
PID = "PID=" & UploadProgress.CreateProgressID()
barref = mainAppPath&"/static/framebar.asp?to=10&" & PID
%>

<%
useSalts = True
hasStructure = True
allowBatches = True
If isInteger(request.querystring("groupId")) And groupId <> "0" Then
	isGroup = True
	groupId = request.querystring("groupId")
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
	If session("regRestrictedGroups") <> "" Then
		strQuery = strQuery & " AND id NOT IN ("&session("regRestrictedGroups")&")"
	End if
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		If rec("useSalts") = 0 Then
			useSalts = False
		End if	
		If rec("hasStructure") = 0 Then
			hasStructure = False
		End If
		If rec("allowBatches") = 0 Then
			allowBatches = False
		End if
	Else
		title = "Error"
		message = "Group does not exist or you are not authorized to access it."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
	End if
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg
Else
	isGroup = False
End if
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript">

function RegShowProgress()
{
	strAppVersion = navigator.appVersion;
	// replaceKey is required
	if (document.getElementById("replaceKey").value == "-1") {
		alert("Please select a key field.")
		return false;
	}
	else if (document.getElementById("file_1").value != "") {
		if (strAppVersion.indexOf('MSIE') != -1 && strAppVersion.substr(strAppVersion.indexOf('MSIE') + 5, 1) > 4) {
			winstyle = "dialogWidth=385px; dialogHeight:140px; center:yes";
			window.showModelessDialog('<% = barref %>&b=IE', null, winstyle);
		}
		else {
			window.open('<% = barref %>&b=NN', '', 'width=370,height=115', true);
		}
	}
	else
	{
		alert("Please select a file.")
		return false;
	}

	return true;
}

</script>

<div class="registrationPage">
<h1>Update Batches</h1>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, name FROM groupCustomFields WHERE visible<>0 ORDER BY name ASC"
rec.open strQuery,jchemRegConn,3,3
wasBlank = False
If Not rec.eof Then
	%>
	<label for="whichGroup">Field Group</label>
	<select id="whichGroup" name="whichGroup" onchange="window.location='importB.asp?groupId='+this.options[this.selectedIndex].value;">
		<%If not hideSmallMolecule then%><option value="0">Small Molecule</option><%End if%>
	<%
Else
	wasBlank = true
End if

Do While Not rec.eof
	%>
	<option value="<%=rec("id")%>" <%If CStr(groupId)=CStr(rec("id")) then%>SELECTED<%End if%>><%=rec("name")%></option>
	<%
	rec.movenext
Loop
If Not wasBlank Then
	%></select><br/><%
End if
rec.close
Set rec = Nothing
%>
<form method="post" action="importUpload.asp?<%=PID %>&fid=<%=getRandomNumber(12)%>&source=batches&groupId=<%=request.querystring("groupId")%>&sdId=<%=request.querystring("sdId")%>&random=<%=rnd%>" OnSubmit="return RegShowProgress()" ENCTYPE="multipart/form-data">
<input type="file" id="file_1" name="file_1">
<div style="display:none;">
<h2>Batch Behavior</h2>
<input type="radio" name="makeBatches" value="DONT_MAKE_BATCHES" style="margin-left:5px;">Ignore Duplicates
<br/>
<input type="radio" name="makeBatches" value="MAKE_BATCHES" style="margin-left:5px;">Treat Duplicates as Batches
</div>
<br/>
<input type="radio" name="makeBatches" value="REPLACE_ON_KEY" style="margin-left:5px;" checked>Key Field:
<select name="replaceKey" id="replaceKey">
<option value="-1">---SELECT---</option>
<option value="reg_id">Registration Id</option>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT actualField, displayName FROM customFields where dataType != 'file' ORDER BY displayName ASC"
rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
%><option value="<%=rec("actualField")%>" <%If rec("displayName")="Notebook Page" then%>SELECTED<%End if%> ><%=rec("displayName")%></option><%
rec.movenext
Loop
rec.close
Set rec = Nothing
Call disconnectJchemReg
%>
</select>
<%'qqq%>

<br>
<br/>
<input type="hidden" name="updateRecords" value="yes">
<input type="submit" value="UPLOAD" name="importSubmit">
</form>
</div>

<!-- #include file="../_inclds/footer-tool.asp"-->