<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<%
sectionID = "tool"
subSectionID="reagentDb"
If session("role") <> "Admin" Then
	response.redirect(mainAppPath&"/logout.asp")
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

function ShowProgress()
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
<h1>Upload Reagent Database</h1>
<form method="post" action="<%=mainAppPath%>/admin/reagentDatabaseUpload.asp?<% = PID %>&fid=<%=getRandomNumber(12)%>&source=compounds" OnSubmit="ShowProgress()" ENCTYPE="multipart/form-data">
<input type="file" id="file_1" name="file_1">
<br>
<input type="submit" value="UPLOAD" name="importSubmit">
</form>
</div>
<div>

<br />
<hr />
<br />

<h1>Fields For Reagent Database SD File</h1>
<h2><code>&gt; &lt;Chemical Name&gt;</code></h2>
<p>-displayed in stochiometry grid<br />
-displays in quick view if the show full chemical name in quick view is set</p>
<h2><code>&gt; &lt;Molecular Formula&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Molecular Weight&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Supplier&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;CAS Number&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Reg Number&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Barcode&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Molarity&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Density&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Solvent&gt;</code></h2>
<p>-displayed in stochiometry grid</p>
<h2><code>&gt; &lt;Trivial Name&gt;</code></h2>
<p>-shown in tab name<br />
-displays in quick view if the show full chemical name in quick view is not set<br />
-name displayed in list of reagents</p>
</div>
<br />
<div>
  <h3>Note: Uploading a new reagent database SD file will remove your current custom reagent database</h3>
</div>
	<!-- #include file="../_inclds/footer-tool.asp"-->