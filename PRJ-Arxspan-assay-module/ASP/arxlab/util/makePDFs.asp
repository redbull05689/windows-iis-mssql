<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout = 180000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_getExperimentStatus.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
pdfFooterOptions = getCompanySpecificSingleAppConfigSetting("pdfFooterOptions", session("companyId"))
pdfHeaderOptions = getCompanySpecificSingleAppConfigSetting("pdfHeaderOptions", session("companyId"))
pdfFooterOptionsRight = getCompanySpecificSingleAppConfigSetting("pdfFooterOptionsRight", session("companyId"))
function getOtherPDFInfo(experimentId,experimentType,witnessName)
	prefix = GetPrefix(experimentType)
	tableName = GetExperimentView(prefix)
	Set expRec = server.CreateObject("ADODB.recordSet")
	strQuery = "SELECT * FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
	expRec.open strQuery,connAdm,0,-1
	str = ""
	str = str & ",'experimentName' : '" & pEscape(expRec("name")) & "'"
	If pdfHeaderOptions <> "" Then
		str = str & ",'headerOptions':"&pdfHeaderOptions
	Else
		str = str & ",'headerOptions':[]"
	End if
	If pdfFooterOptions <> "" Then
		str = str & ",'footerOptions':"&pdfFooterOptions
	Else
		str = str & ",'footerOptions':[]"
	End If
	If pdfFooterOptionsRight <> "" Then
		str = str & ",'footerOptionsRight':"&pdfFooterOptionsRight
	Else
		str = str & ",'footerOptionsRight':[]"
	End if
	str = str & ",'signerName':'"&pEscape(expRec("firstName")&" "&expRec("lastName"))&"'"
	str = str & ",'ownerName':'"&pEscape(expRec("firstName")&" "&expRec("lastName"))&"'"
	str = str & ",'witnessName':''"
	str = str & ",'companyId':"&session("companyId")
	str = str & ",'experimentStatus':'"&pEscape(expRec("status"))&"'"
	expRec.close
	Set expRec = nothing
	getOtherPDFInfo = str
end function

if session("email")="support@arxspan.com" or session("email")="skicomputing@mskcc.org" then
	if request.form("submitIt") <> "" Then

		Call getconnectedadm
		experimentIds = Split(request.Form("experimentIds"),",")
		For xx = 0 To UBound(experimentIds)

			' Find the revision Number (if requested)
			revisionNumber = request.form("revisionNumber")
			if Request.Form("lastRev") <> "" then
				revisionNumber = getExperimentRevisionNumber(request.form("experimentType"),Trim(experimentIds(xx)))
			end if

			' Figure out if we should sign it or not
			status = getExperimentStatus(request.form("experimentType"),Trim(experimentIds(xx)),revisionNumber, true)
			sign = false
			witnessed = false
			if status = "signed - closed" then
				sign = true
			elseif status = "witnessed" then
				witnessed = true
			end if

			' Make the PDF record
			response.write("type: " + request.form("experimentType") + "<br />")
			response.write("ID: " + Trim(experimentIds(xx)) + "<br />")
			response.write("revisionNumber: " + revisionNumber + "<br />")
			response.write("status: " + cstr(status) + "<br />")
			response.write("sign: " + Cstr(sign) + "<br />")
			response.write("witnessed: " + Cstr(witnessed) + "<br />")
			response.write("<hr />")

			if not witnessed then
				a = savePDF(request.form("experimentType"),Trim(experimentIds(xx)),revisionNumber,sign,true,false)
				' response.write(a)
			else
			
				Call getconnectedadm
				foundIt = false
				experimentType = request.Form("experimentType")
				experimentId = Trim(experimentIds(xx))
				revisionNumber = revisionNumber - 1 'Weird requiremnt of witnessed experiments (it needs to know the signed version)
				prefix = GetPrefix(experimentType)
				suffix = GetAbbreviation(experimentType)
				tableName = GetFullName(prefix, "experiments", true)

				Set rec = server.CreateObject("ADODB.Recordset")
				strQuery = "SELECT * FROM witnessRequestsView WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentTypeId="&SQLClean(experimentType,"N","S")&" AND accepted=1 ORDER BY id desc"
				rec.open strQuery,connAdm,0,-1
				If Not rec.eof Then
					foundIt = True
					witnessName = rec("requesteeFirstName")&" "&rec("requesteeLastName")
					witnessUserId = rec("requesteeId")
					ownerId = rec("requesterId")
					Set rec2 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM usersView WHERE id="&SQLClean(witnessUserId,"N","S")
					rec2.open strQuery,connAdm,0,-1
					If Not rec2.eof Then
						witnessEmail = rec2("email")
					End If
					rec2.close
					Set rec2 = nothing

					Set rec2 = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
					rec2.open strQuery,connAdm,0,-1
					If Not rec2.eof Then
						If session("useGMT") Then
							theDate = rec2("dateUpdated")
						Else
							theDate = rec2("dateUpdatedServer")
						End If
					End If
					rec2.close
					Set rec2 = nothing

					If session("useGMT") Then
						theDate = theDate & " (GMT)"
					Else
						theDate = theDate & " (EST)"
					End if
				End if
				rec.close
				Set rec = nothing

				If foundIt then

					signTable = "<table width='250'>"
					signTable = signTable & "<tr><td style='font-weight:bold;font-size:18px;' colspan='2'>Witness Information</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>Name</td><td>"&witnessName&"</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>User Id</td><td>"&witnessUserId&"</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>Email</td><td>"&witnessEmail&"</td></tr>"
					signTable = signTable & "<tr><td style='font-weight:bold;'>Date</td><td>"&theDate&"</td></tr>"
					signTable = signTable & "</table>"

					pythonD = "{'signTable' : '"&Replace(signTable,"'","\'")&"'"&getOtherPDFInfo(experimentId,experimentType,witnessName)&"}"


					Set uRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
					uRec.open strQuery,connAdm,3,3
					userId = uRec("userId")
					experimentName = uRec("name")

					'Create a record in the pdfProcQueue table for the witness report		
					strQuery = "INSERT INTO [pdfProcQueue] (serverName, companyId, userId, experimentId, revisionNumber, experimentType, fileType, jsonBODY, dateCreated, status) VALUES (" & SQLClean(whichServer,"T","S") & ", " & SQLClean(getCompanyIdByUser(ownerId),"N","S") & ", " &SQLClean(ownerId,"N","S") & ", " & SQLClean(experimentId,"N","S") & ", " & SQLClean(revisionNumber,"N","S") & ", " & SQLClean(suffix, "T", "S") &  ", " &	SQLClean("witness","T","S") & ", " &	SQLClean(pythonD,"T","S") & ", SYSDATETIME(), 'NEW')" 
					connAdm.execute(strQuery)
					' response.write(strQuery)
				End if
				Call disconnectadm
			end if

		next
		Call disconnectadm
	end if
%>
	<form action="makePDFs.asp" method="POST">
		experimentType<br/>
		<select name="experimentType">
			<option value="1">Chem</option>
			<option value="2">Bio</option>
			<option value="3">Free</option>
			<option value="4">Anal</option>
			<option value="5">Cust</option>
		</select><br/>
		experimentIds (comma separated)<br/>
		<input type="text" name="experimentIds"><br/>
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