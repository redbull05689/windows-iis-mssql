<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
'this script is loaded into an IFrame on the signed.asp/show PDF version of experiment page.  It waits for the target file to exist on the drive
'while it does not exist it displays a processing icon and retries every 2 secdonds.
'when the file does exist it redirects to show sign to show the PDF

'get querystring params
experimentId = request.querystring("id")
experimentType = request.querystring("experimentType")
revisionNumber = request.querystring("revisionNumber")

'set safe version flag
If LCase(request.querystring("safeVersion")) = "true" Then
	safeVersion = true
End if

'only users who can view the experiment can access this page
If canViewExperiment(experimentType,experimentId,session("userId")) then
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	'get the PDF's path and name
	prefix = GetPrefix(experimentType)
	abbrv = GetAbbreviation(experimentType)
	historyTableView = GetFullName(prefix, "experimentHistoryView", true)
	strQuery = "SELECT userId, experimentId, revisionNumber from " & historyTableView & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber="&SQLClean(revisionNumber,"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof then
		pdfName = uploadRootRoot & "\" & getCompanyIdByUser(rec("userId")) & "\"&rec("userId")&"\"&rec("experimentId")&"\"&rec("revisionNumber")&"\" & abbrv
	End if
	rec.close

	' Figure out if we have any outstanding records in ERROR status.
	' 6553: Ignore the error if the last process on the same experiment and same revision was successful.
	strQuery = "SELECT COUNT(*) AS recordCount" &_
		" FROM pdfProcQueue o" &_
		" WHERE companyId=" & session("companyId") &_
		" AND experimentId=" & SQLClean(experimentId,"N","S") &_
		" AND revisionNumber=" & SQLClean(revisionNumber,"N","S") &_
		" AND status='ERROR'" &_
		" AND NOT EXISTS (SELECT 1 FROM pdfProcQueue i WHERE i.companyid = o.companyid AND i.experimentId = o.experimentId AND i.revisionNumber = o.revisionNumber AND i.id > o.id AND i.status = 'processed');"

	rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	recordCount = rec("recordCount")
	rec.close
	set rec = Nothing

	' if the record is in error status then tell the user
	If recordCount <> 0 Then%>
		<script>
			parent.swal({
				title: "PDF Error",
				type: "warning",
				text: "There was an error rendering this PDF.\n Please contact Arxspan support."
				},
				function isConfirm(isConfirm) {
					if (isConfirm) {
						parent.location.href = "<%=mainAppPath%>/support-request.asp?pdfErr=1&expId=<%=experimentId%>&expType=<%=experimentType%>"
					}
				});
		</script>
	<%Else
		pdfName = pdfName & "\sign"

		'append to the filename as necessary based on flags
		If request.querystring("short") = "1" Then
			pdfName = pdfName & "-short"
		End if
		If safeVersion Then
			pdfName = pdfName & "-sign.pdf"
		Else
			pdfName = pdfName & ".pdf"
		End if

		'make error if the PDF exists but cannot be loaded for some reason, perhaps it is 0 bytes
		pdfError = False
		On Error Resume next
		Set adoStream = CreateObject("ADODB.Stream")
		adoStream.Open()
		adoStream.Type = 1  
		adoStream.LoadFromFile(pdfName)
		If Err.number <> 0 Then
			pdfError = true
		End If
		Set adoStream = Nothing
		On Error goto 0


		'if the file exists and we were successful at opening it
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(pdfName) And Not pdfError Then
		%>
			<script type="text/javascript">
				<%'detect whther we are on an IPAD this use to add a flag that would redirect to a different page.  That is no longer the case%>
				if (navigator.userAgent.match(/iPad/i) != null)
				{
					window.parent.location = "<%=mainAppPath%>/experiments/showSign.asp?id=<%=experimentId%>&experimentType=<%=request.querystring("experimentType")%>&revisionNumber=<%=revisionNumber%>&safeVersion=<%=request.querystring("safeVersion")%>&short=<%=request.querystring("short")%>";
				}
				else
				{
					<%if request.querystring("fromSign")="true" then 
					'this was changed for amicus. this call use to be under the location change%>
					window.parent.softSign();
					<%end if%>
					//redirect to view PDF
					window.location = "<%=mainAppPath%>/experiments/showSign.asp?id=<%=experimentId%>&experimentType=<%=request.querystring("experimentType")%>&revisionNumber=<%=revisionNumber%>&safeVersion=<%=request.querystring("safeVersion")%>&short=<%=request.querystring("short")%>";
					<%if request.querystring("credError")="1" then%>
					<%'this error is a workaround for safe/verizon sometimes Verizon (at least they use to) sends back a bad response instead of a code when the user misentered their credentials instead of 
					'properly handling the error in their login screen%>
					window.parent.alert("There was a problem applying your signature to the document.  The most frequent cause of this is mis-entered credentials.  Please try again.");
					<%end if%>
				}

			</script>
		<%
		Else
			'if the file does not exist reload the page every 2 seconds
		%>
			processing<img src="<%=mainAppPath%>/images/ajax-loader.gif">
			<script type="text/javascript">
				setTimeout('location.reload(true)',2000)
			</script>
		<%
		End If	
	End If
	%>
<%End if%>