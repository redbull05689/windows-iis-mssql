<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
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
strQuery = "SELECT 1 FROM sdImportsView WHERE fid="&SQLClean(fid,"T","S")&" AND allowBatches=0"
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	response.redirect(mainAppPath&"/static/errorMessage.asp?message=Batches are not allowed for this field group.")
End If
rec.close
Set rec = Nothing
Call disconnectJchemReg

If request.Form("formSubmitted") <> "" then
	newFid = getRandomNumber(12)
	bulkRegEndpointUrl = getCompanySpecificSingleAppConfigSetting("bulkRegEndpointUrl", session("companyId"))

	Call getConnectedJchemReg
	strQuery = "SELECT * FROM sdImports WHERE fid="&SQLClean(fid, "T", "S")
	Set rs = jchemRegConn.execute(strQuery)
	If Not rs.eof Then
		oldUploadId = rs("newUploadId")
		strQuery = "INSERT INTO sdImports(userId,userName,sdFilename,dateCreated,dateCreatedUTC,needsPurification,outForAnalysis,analysisComplete,fid,groupId) output inserted.id as newId values("&_
					rs("userId") &","&_
					"'"&rs("userName") &"',"&_
					"'"&rs("sdFilename") &"',"&_
					"'"&rs("dateCreated") &"',"&_
					"'"&rs("dateCreatedUTC") &"',"&_
					rs("needsPurification") &","&_
					rs("outForAnalysis") &","&_
					rs("analysisComplete") &","&_
					newFid &","&_
					rs("groupId")&")"
		Set rs2 = jchemRegConn.execute(strQuery)
		sdId = rs2("newId")
		rs2.close
		Set rs2 = Nothing		

		' CALL REST SERVICE TO GET UPLOAD ID HERE
		payload = "{""sourceUploadId"":"""&oldUploadId&""",""makeBatchesConfig"":""MAKE_BATCHES"",""arxspan_sd_source_id"":"""&sdId&"""}"
		
		Set http = CreateObject("MSXML2.ServerXMLHTTP")
		http.open "POST", bulkRegEndpointUrl&"/initUpload", True
		http.setRequestHeader "Content-Type", "application/json"
		http.setRequestHeader "Content-Length", Len(data)

		http.SetTimeouts 180000,180000,180000,180000
		' ignore ssl cert errors
		http.setOption 2, 13056
		http.send payload
		http.waitForResponse(180)

		Set newUpload = JSON.Parse(http.responseText)
		if newUpload.Exists("status") and newUpload.Get("status") = "success" and newUpload.Exists("uploadId") Then
			uploadId = newUpload.Get("uploadId")
			strQuery = "UPDATE sdImports SET newUploadId="&SQLClean(uploadId,"T","S")&" WHERE id="&sdId
			jchemRegConn.execute(strQuery)
		Else
			strQuery = "DELETE FROM sdImports WHERE id="&sdId
			jchemRegConn.execute(strQuery)
			Response.Status = "404 Upload Not Created"
			response.end()	
		End If
	End If
	rs.close
	Set rs = Nothing
	Call disconnectJchemReg

	response.redirect("importProgress.asp?fid="&newFid)
End if
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<div class="registrationPage">
<h1>Add Batches</h1>
<form method="post" action="takeLogMakeBatch.asp?fid=<%=request.querystring("fid")%>" id="theForm">
	<input type="hidden" value="submitted" name="formSubmitted" id="formSubmitted">
	<input type="submit" value="ADD BATCHES" id="formSubmitButton" name="formSubmitButton">
</form>
<p>Please Wait</p>
<script type="text/javascript">
	window.setTimeout("document.getElementById('theForm').submit()",2000)
</script>
</div>
	<!-- #include file="../_inclds/footer-tool.asp"-->