<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<%
server.scripttimeout = 250000
response.buffer = false
%>
<%
sectionId = "reg"
subSectionId = "import"
subSubSectionId = "progress"
if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If
%>
<%
	fid = request.querystring("fid")

	Call getconnectedJchemReg
	allowBatches = True
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT allowBatches FROM sdImportsView WHERE fid="&SQLClean(fid,"T","S")&" AND allowBatches=0"
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		allowBatches = False
	End If
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript">
var numLoads = 0;
var reloadInterval = window.setInterval("goProgress()", 1500)
	function goProgress() {
		$.ajax({
			url: "getProgress.asp?fid=<%=fid%>",
			type: "GET",
			cache: false,
			dataType: "json",
		})
		.success(function (response) {
			percentComplete = response[0];
			status2 = response[1];
			duplicates = response[2];
			totalRecords = response[3];
			recordsProcessed = response[4];
			errors = response[5];

			document.getElementById("progressBar").style.width = percentComplete * 3 + "px";
			document.getElementById("percentCompleteTD").innerHTML = percentComplete + "%";
			document.getElementById("statusTD").innerHTML = status2;

			if (recordsProcessed == 0 && totalRecords == 0) {
				document.getElementById("recordsProcessedTD").innerHTML = "wait";
			}
			else {
				document.getElementById("recordsProcessedTD").innerHTML = recordsProcessed + "/" + totalRecords;
			}

			document.getElementById("duplicatesTD").innerHTML = duplicates;
			document.getElementById("errorsTD").innerHTML = errors;
			console.log("percentComplete: ", percentComplete);

			if (percentComplete == 100) {
				document.getElementById("downloadReportLink").style.display = 'block';
				document.getElementById("downloadReportMessage").style.display = 'none';
				<%if request.querystring("source") = "compounds" and allowBatches then %>
					document.getElementById("addBatchesButton").style.display = 'block';
				<% end if%>
				if (reloadInterval != null || numLoads > 0) {
					if (reloadInterval != null) {
						console.log("clearing interval");
						window.clearInterval(reloadInterval);
						reloadInterval = null;
						console.log("clear interval complete");
					}

					if (numLoads <= 5) {
						console.log("reloading status");
						window.setTimeout("goProgress()", 1500);
						numLoads += 1;
					}

					if (numLoads == 5) {
						document.getElementById("loadingImg").src = '<%=mainAppPath%>/images/reg-import-loading-done.gif'
					}
				}
			}
		})
		.fail(function (e) {
			console.log("importProgress.asp getProgress error: ", e);
		})
		.always(function () {
		});
	}
</script>

<div class="registrationPage">
<h1>Import SDFile</h1>
<div id="progressBox" style="border:10px solid black;padding:10px;">
<table style="width:100%">
<tr>
<td align="center">
<table>
<tr style="height:200px;">
<td colspan="2" align="center">
<img border="0" style="border:none;" src="<%=mainAppPath%>/images/reg-import-loading.gif" id="loadingImg">
</td>
</tr>
<tr>
<td colspan="2">
<div id="progressHolder" style="width:300px;border:1px solid black;padding:2px;">
<div id="progressBar" style="background-color:black;height:20px;">
</div>
</div>
</td>
</tr>
<tr>
<td>
Status
</td>
<td id="statusTD">
</td>
</tr>
<tr>
<td>
Percent Complete
</td>
<td id="percentCompleteTD">
</td>
</tr>
<tr>
<td>
Records Processed
</td>
<td id="recordsProcessedTD">
</td>
</tr>
<tr>
<td>
Duplicates
</td>
<td id="duplicatesTD">
</td>
</tr>
<tr>
<td>
Errors
</td>
<td id="errorsTD">
</td>
</tr>
<tr>
<td>
Report
</td>
<td id="downloadReportTD">
<div id="downloadReportLink" style="display:none;">
<a href="services/get-upload-report-file.asp?fid=<%=request.querystring("fid")%>">Download Now</a>
</div>
<div id="downloadReportMessage" style="display:block;">
Still Working...
</div>
</td>
</tr>
</table>
</td>
</tr>
</table>
</div>
<p>You may navigate away from this page during the import.  The progress will be reflected in the left nav.</p>
</div>
<div class="registrationPage">
<div id="addBatchesButton" style="float:right;display:none;">
	<input type="Button" value="ADD BATCHES" onclick="window.location.href='takeLogMakeBatch.asp?fid=<%=request.querystring("fid")%>'">
</div>
<div style="height:1px;clear:both;"></div>
</div>
<!-- #include file="../_inclds/footer-tool.asp"-->