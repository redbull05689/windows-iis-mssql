<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout = 180000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_getExperimentStatus.asp" -->
<%

if session("email")="support@arxspan.com" then
	if request.form("submitIt") <> "" Then

		Call getconnectedadm
		experimentId = request.Form("experimentId")

		' Find the revision Number (if requested)
		revisionNumber = request.form("revisionNumber")
		if Request.Form("lastRev") <> "" then
			revisionNumber = getExperimentRevisionNumber("1", experimentId)
		end if

		Set rec = server.CreateObject("ADODB.RecordSet")
		infoQuery = "SELECT userId, cdx FROM experiments WHERE id=" & experimentId
		rec.open infoQuery, connAdm, 3, 3

		if not rec.eof then
			'companyId = rec("companyId")
			userId = CSTR(rec("userId"))
			cdxData = Replace(rec("cdx"),"\\""","\""")

			Set userRec = server.CreateObject("ADODB.RecordSet")
			userQuery = "SELECT companyId, hasCompoundTracking FROM usersView WHERE id=" & userId
			userRec.open userQuery, connAdm, 3, 3

			if not userRec.eof then	
				companyId = CSTR(userRec("companyId"))
				hasCompoundTracking = CSTR(Abs(userRec("hasCompoundTracking")))

				filepath = "c:\inbox\{whichServer}_{companyId}_{userId}_{experimentId}_{revisionNumber}_{compoundTracking}_new_rxn.rxn"
				filepath = Replace(filepath, "{whichServer}", whichServer)
				filepath = Replace(filepath, "{companyId}", companyId)
				filepath = Replace(filepath, "{userId}", userId)
				filepath = Replace(filepath, "{experimentId}", experimentId)
				filepath = Replace(filepath, "{revisionNumber}", revisionNumber)
				filepath = Replace(filepath, "{compoundTracking}", hasCompoundTracking)

				response.write("company ID: " + companyId + "<br />")
				response.write("user ID: " + userId + "<br />")
				response.write("ID: " + experimentId + "<br />")
				response.write("revisionNumber: " + revisionNumber + "<br />")
				response.write("Has Compound Tracking: " + hasCompoundTracking + "<br />")
				response.write("File Path: " + filepath + "<br />")
				response.write("<hr />")

				set fs=Server.CreateObject("Scripting.FileSystemObject")
				set tfile=fs.CreateTextFile(filepath,false,true)
				tfile.WriteLine(Replace(Replace(Replace(cdxData,"\""",""""),"HeightPages=""1""","HeightPages=""5"""),"WidthPages=""1""","WidthPages=""5"""))
				tfile.close
				set tfile=nothing
				set fs=Nothing
				a = logAction(2,experimentId,"",25)
			end if

			userRec.close
		end if

		rec.close

		'a = savePDF(request.form("experimentType"),Trim(experimentIds(xx)),revisionNumber,sign,true,false)
		' response.write(a)

		Call disconnectadm
	end if
%>
	<form action="reprocRXN.asp" method="POST">
		experimentId<br/>
		<input type="text" name="experimentId"><br/>
		revisionNumber<br/>
		<input type="text" id="revisionNumber" name="revisionNumber" disabled><br/>
		Use Newest Revision<br />
		<input type="checkbox" id="lastRev" name="lastRev" checked /><br /><br />
		<input type="submit" name="submitIt">
	</form>

<script>
document.getElementById('lastRev').onchange = function() {
    document.getElementById('revisionNumber').disabled = this.checked;
};
</script>

<%
end if
%>