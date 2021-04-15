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
subSectionId = "import0"
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
groupId = request.querystring("groupId")
If isInteger(request.querystring("groupId"))  And groupId <> "0" Then
	isGroup = True
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT useSalts, hasStructure, allowBatches FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
	If session("regRestrictedGroups") <> "" Then
		strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
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
	groupId = 0
End if
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript">
function updateFieldGroupSelection()
{
    document.getElementById("fileInputButtonHolder").style.display = "none";
    document.getElementById("loadingFieldsMessageHolder").style.display = "block";
    window.location = 'importC.asp?groupId=' + document.getElementById("whichGroup").options[document.getElementById("whichGroup").selectedIndex].value;
}

function RegShowProgress()
{
  strAppVersion = navigator.appVersion;
  if (document.getElementById("file_1").value != "")
  {
    if (strAppVersion.indexOf('MSIE') != -1 && strAppVersion.substr(strAppVersion.indexOf('MSIE')+5,1) > 4)
    {
      winstyle = "dialogWidth=385px; dialogHeight:140px; center:yes";
      window.showModelessDialog('<% = barref %>&b=IE',null,winstyle);
    }
    else
    {
      window.open('<% = barref %>&b=NN','','width=370,height=115', true);
    }
  }
  return true;
}

</script>

<div class="registrationPage">
<h1>Register Compounds</h1>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, name FROM groupCustomFields WHERE visible<>0"
If session("regRestrictedGroups") <> "" Then
	strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
End If
strQuery = strQuery & " ORDER BY name ASC"
rec.open strQuery,jchemRegConn,3,3
wasBlank = False
If Not rec.eof Then
	%>
	<label for="whichGroup">Field Group</label>
	<select id="whichGroup" name="whichGroup" onchange="updateFieldGroupSelection()">
		<%If Not hideSmallMolecule then%><option value="0">Small Molecule</option><%End if%>
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
<form method="post" action="importUpload.asp?<% = PID %>&fid=<%=getRandomNumber(12)%>&source=compounds&groupId=<%=request.querystring("groupId")%>&sdId=<%=request.querystring("sdId")%>&random=<%=rnd%>" OnSubmit="RegShowProgress()" ENCTYPE="multipart/form-data">
<div id="loadingFieldsMessageHolder" style="display:none;">Loading fields for group...</div>
<div id="fileInputButtonHolder" style="display:block;">
<input type="file" id="file_1" name="file_1">
<div style="display:none;">
<h2>Batch Behavior</h2>
<input type="radio" name="makeBatches" value="DONT_MAKE_BATCHES" style="margin-left:5px;" checked>Ignore Duplicates
<br/>
<input type="radio" name="makeBatches" value="MAKE_BATCHES" style="margin-left:5px;">Treat Duplicates as Batches
<br/>
<input type="radio" name="makeBatches" value="REPLACE_ON_KEY" style="margin-left:5px;">Key Field:
<select name="replaceKey" id="replaceKey">
<option value="-1">---SELECT---</option>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT actualField, displayName FROM customFields ORDER BY displayName ASC"
rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
%><option value="<%=rec("actualField")%>"><%=rec("displayName")%></option><%
rec.movenext
Loop
rec.close
Set rec = Nothing
Call disconnectJchemReg
%>
</select>
<%'qqq%>

<%If 1=1 then%>
<h2>Needs Purification</h2>
<input type="hidden" name="keyField" id="keyField" value="Needs_Purification">
<select name="needsPurification" id="needsPruification" style="margin-left:5px;">
<option value="-1">---SELECT---</option>
<option value="True">True</option>
<option value="False" SELECTED>False</option>
</select>
<%End if%>
</div>
<br>
<input type="submit" value="UPLOAD" name="importSubmit">
</div>
</form>
<form name="ignore_me">
    <input type="hidden" id="page_is_dirty" name="page_is_dirty" value="0" />
</form>
<script type="text/javascript">
	var dirty_bit = document.getElementById('page_is_dirty');
	if (dirty_bit.value == '1') window.location.reload();
	function mark_page_dirty() {
	    dirty_bit.value = '1';
	}
	mark_page_dirty()
</script>
</div>

<!-- #include file="../_inclds/footer-tool.asp"-->