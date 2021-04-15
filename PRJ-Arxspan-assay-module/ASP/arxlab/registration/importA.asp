<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->

<%
sectionId = "reg"
subSectionId = "import1"
if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If
%>
<%
Set UploadProgress = Server.CreateObject("Persits.UploadProgress")
PID = "PID=" & UploadProgress.CreateProgressID()
barref = mainAppPath&"/static/framebar.asp?to=10&" & PID
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript">

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
<h1>Register Batches</h1>
<form method="post" action="importUpload.asp?<% = PID %>&fid=<%=getRandomNumber(12)%>&source=batches&random=<%=rnd%>" OnSubmit="RegShowProgress()" ENCTYPE="multipart/form-data">
<input type="file" id="file_1" name="file_1">
<div style="display:none;">
<h2>Batch Behavior</h2>
<input type="radio" name="makeBatches" value="DO_BOTH" style="margin-left:5px;" checked>Ignore Duplicates
<br/>
<input type="radio" name="makeBatches" value="MAKE_BATCHES" style="margin-left:5px;">Treat Duplicates as Batches
<br/>
<input type="radio" name="makeBatches" value="REPLACE_ON_KEY" style="margin-left:5px;">Key Field:
<select name="replaceKey" id="replaceKey">
<option value="-1">---SELECT---</option>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM customFields ORDER BY displayName ASC"
rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
%><option value="<%=rec("actualField")%>"><%=rec("displayName")%></option><%
rec.movenext
Loop
rec.close
Set rec = nothing
Call disconnectJchemReg
%>
</select>
<%'qqq%>
</div>
<br>
<input type="submit" value="UPLOAD" name="importSubmit">
</form>
</div>

	<!-- #include file="../_inclds/footer-tool.asp"-->