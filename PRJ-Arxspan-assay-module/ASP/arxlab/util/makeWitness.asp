<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
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

if session("email") = "support@arxspan.com" then

	if request.form("submitIt") <> "" Then
		Call getconnectedadm
		foundIt = false
		experimentType = request.Form("experimentType")
		experimentId = request.Form("experimentId")
		revisionNumber = request.Form("revisionNumber")

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


'			set fs=Server.CreateObject("Scripting.FileSystemObject")
'			set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(ownerId)&"_"&ownerId&"_"&experimentId&"_"&revisionNumber&"_"&suffix&".witness")
'			tfile.WriteLine(pythonD)
'			tfile.close
			set tfile=nothing
			set fs=Nothing
		End if
		Call disconnectadm
	end if
%>
	<form action="makeWitness.asp" method="POST">
		experimentType<br/>
		<input type="text" name="experimentType"><br/>
		experimentId<br/>
		<input type="text" name="experimentId"><br/>
		revisionNumber<br/>
		<input type="text" name="revisionNumber"><br/>
		<input type="submit" name="submitIt">
	</form>
<%
end if
%>