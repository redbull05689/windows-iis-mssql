<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="./returnImageFile.asp"-->
<%
experimentId = request.querystring("experimentId")
revisionNumber =request.querystring("revisionNumber")
noOfTries = CInt(request.querystring("c"))
sendWhiteGif = false

If isEmpty(Request.QueryString("c")) Then
	noOfTries = 240
End If

sendWhiteGif = request.querystring("qs")

experimentType = 1
stepNumber = request.querystring("stepNumber")
If canViewExperiment(1,experimentId,session("userId")) then
	Call getconnected
	
	If revisionNumber = "" Then
		strQuery = "SELECT userId,revisionNumber,id,LEN(cdx) as cdxLength FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT userId,revisionNumber,id,LEN(cdx) as cdxLength FROM experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") 
	End If

	cdxLength = 0
	filename = "rxn.gif"
	Set iRec = server.CreateObject("ADODB.RecordSet")
	iRec.open strQuery,conn,3,3
	
	If Not iRec.eof Then
		cdxLength = CLng(iRec("cdxLength"))
		If revisionNumber = "" then
			filepath = uploadRootRoot &"\" & session("companyId") & "\" & iRec("userId") & "\" & experimentId & "\" & getExperimentRevisionNumber(1,experimentId) & "\chem\chemData\"
		Else
			filepath = uploadRootRoot &"\" & session("companyId") & "\" & iRec("userId") & "\" & experimentId & "\" & revisionNumber & "\chem\chemData\"
		End If

		If stepNumber <> "" Then
			If revisionNumber = "" then
				filename = "rxn-"&stepNumber&".gif"
				filepath = uploadRootRoot &"\" & getCompanyIdByUser(iRec("userId")) & "\" & iRec("userId") & "\" & experimentId & "\" & getExperimentRevisionNumber(1,experimentId) & "\chem\chemData\"
			Else
				filename = "rxn-"&stepNumber&".gif"
				filepath = uploadRootRoot &"\" & getCompanyIdByUser(iRec("userId")) & "\" & iRec("userId") & "\" & experimentId & "\" & revisionNumber & "\chem\chemData\"
			End if
		End if
		iRec.close
	End If
	Set iRec = Nothing

	response.contenttype="image/gif"
	response.addheader "ContentType","image/gif"
	response.addheader "Content-Disposition", "inline; " & "filename=chem-"&experimentId&".gif"
	
	If Not sendWhiteGif	Then
		returnedFile = False
		If cdxLength > 0 Then
			numRetries = 0
			sleepSql = "WAITFOR DELAY '00:00:00:250'"
			
			Do While (Not returnedFile) And numRetries < noOfTries
				conn.execute(sleepSql)
				numRetries = numRetries + 1
				returnedFile = returnImageFile(filepath, filename, server.mappath(mainAppPath)&"/images/", "return-error")
			Loop
		End If
		
		If Not returnedFile Then
			if not isEmpty(Request.QueryString("c")) then
				response.status = "222"
			else
				Call returnImageFile(filepath, filename, server.mappath(mainAppPath)&"/images/", "white-pixel.gif")
			end if
		End If
	Else
		Call returnImageFile(filepath, filename, server.mappath(mainAppPath)&"/images/", "white-pixel.gif")
	End If
	
End if
%>