<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
subSectionId = "reg-request-compounds"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript" src="<%=mainAppPath%>/js/getBrowserInfo.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/liveEdit/chromeExtChkinChkout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="/arxlab/js/common/liveEditHelperFunctions.js?<%=jsRev%>"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/marvinjslauncher.js"></script>
<script src="<%=mainAppPath%>/_inclds/chemAxon/marvinjs-19.11.0/js/webservices.js"></script>
<script type="text/javascript">
	hasMarvin = <%=LCase(CStr(session("useMarvin"))) %>

	<%If session("useChemDrawForLiveEdit") Then%>
		useChemDrawForLiveEdit = true;
	<%End If%>
</script>
<%
If Not(session("hasAccordInt") And session("regRoleNumber") <= 15) Then
	response.redirect("logout.asp")
End If
%>
<%
Set UploadProgress = Server.CreateObject("Persits.UploadProgress")
PID = "PID=" & UploadProgress.CreateProgressID()
barref = mainAppPath&"/static/framebar.asp?to=10&" & PID
%>
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

function disableSubmitButtons(disable)
{
	document.getElementById("formSubmitButton").disabled = disable;
	document.getElementById("fileSubmitButton").disabled = disable;
	
	document.getElementById("formSubmitButton").value = "Processing...";
	document.getElementById("fileSubmitButton").value = "Processing...";
}

function submitFileForm()
{
	disableSubmitButtons(true);
	$("#fileUploadForm").submit();
}

function submitStructureForm()
{
	disableSubmitButtons(true);
	getChemistryEditorChemicalStructure('mycdx', false, 'cdx')
	.then(function(cdxml) {
		document.getElementById('cdxmlData').value=cdxml;
		document.drawForm.submit();
	});
}
</script>

<h1><%=requestCompoundsLabel%></h1>

<form id="fileUploadForm" method="post" action="process_upload.asp?<% = PID %>" OnSubmit="RegShowProgress()" ENCTYPE="multipart/form-data">
<br/>
<input type="file" id="file_1" name="file_1">
<br>
<input type="button" id="fileSubmitButton" value="UPLOAD" name="importSubmit" style="padding:2px;" onClick="submitFileForm();">
</form>
<br/>
<br/>
<br/>
<h1>Add by structure</h1>
<br/>
<form method="post" name="drawForm" action="process_upload.asp?m=1">
<div style="width:400px;" id="accIndexAspEditorMarkup">
<script type="text/javascript">
    getChemistryEditorMarkup("mycdx", "", "", 400, 400, false).then(function (theHtml) {
        $("#accIndexAspEditorMarkup").html(theHtml);
    });
</script>
</div>
<input type="hidden" name="cdxmlData" id="cdxmlData" value="">
<br/>
<input type="button" id="formSubmitButton" value="UPLOAD" name="importSubmit" style="padding:2px;" onClick="submitStructureForm();">
</form>

<!-- #include file="../_inclds/footer-tool.asp"-->