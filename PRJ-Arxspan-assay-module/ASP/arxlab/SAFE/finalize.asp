<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%response.buffer = false%>
<%Server.ScriptTimeout = 285%>
<!-- #include file="../_inclds/globals.asp" -->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_requestWitness.asp"-->

<!-- #include file="../_inclds/header-tool.asp"-->

<div style="min-height:600px; height: 80vh;">
<br />
<h3 style="text-align:center">Signing PDF...</h3>
	<!-- #include file="spinner.asp"-->
</div>
	<!-- #include file="../_inclds/footer-tool.asp"-->

<%
state = Request.QueryString("state")
'response.write("STATE: "&state)
experimentType = Split(state,"_")(1)
experimentId = Split(state,"_")(2)
revisionNumber = Split(state,"_")(3)
userId = Split(state,"_")(4)
witness = Split(state,"_")(5)
keepOpen = Split(state,"_")(6)
CoAuthorSign = False
isKeepOpen = False
If witness="1" Then
	witness = True
Else
	witness = False
	If keepOpen = "1" Then
		isKeepOpen = True
	' Overloading keepOpen to also track coAuthor signing
	ElseIf keepOpen = "2" Then
		coAuthorSign = True
	End if
End if
prefix = GetPrefix(experimentType)
folderName = GetAbbreviation(experimentType)
experimentTableName = GetFullName(prefix, "experiments", true)
experimentHistoryTableName = GetFullName(prefix, "experimentHistoryView", true)
maxRevisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
'response.write("experiment type: "&experimentType&"<br/>")
'response.write("experiment id: "&experimentId&"<br/>")
'response.write("revisionNumber: "&revisionNumber&"<br/>")
'response.write("user id: "&userId&"<br/>")


set rec2 = server.CreateObject("ADODB.RecordSet")

strQuery = "SELECT userId FROM " & experimentHistoryTableName & " WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND "
if experimentType <> 5 then
	strQuery = strQuery & "experimentType="&SQLClean(experimentType,"N","S") & " AND "
else
	'for custom experiments, the experimentType is NULL in custexperimentHistoryView. Leaving this as an "OR" in case it ever gets fixed
	strQuery = strQuery & "(experimentType="&SQLClean(experimentType,"N","S") & " OR experimentType IS NULL) AND "
end if
strQuery = strQuery & "revisionNumber="&SQLClean(maxRevisionNumber,"N","S")

rec2.open strQuery,conn,3,3
experimentUserId = rec2("userId")
rec2.close
Set rec2 = Nothing


outFilename = uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber+1&"\"&folderName&"\"&"\sign.pdf"


If CStr(userId) = CStr(session("userId")) Then
		
	signFailed = False
	counter = 0
	Do While True And counter < 60
		sleep = 5
		strQuery = "WAITFOR DELAY '00:00:" & right(clng(sleep),2) & "'" 
		connAdm.Execute strQuery,,129 
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		If fs.fileExists(outFilename) Then
			set f=fs.GetFile(outFilename)
			If f.Size <> 0 then
				counter = 1000
			End If
			set f=nothing
		End if
		set fs=Nothing
		counter = counter + 1
	Loop
	If counter <> 1001 Then
		signFailed = True
	End if

	prefix = GetPrefix(experimentType)
	pageName = mainAppPath & "/" & GetExperimentPage(prefix) & "?id="&experimentId

	If Not signFailed then
		strQuery = "UPDATE "&experimentTableName&" set softSigned=1 WHERE id="&SQLClean(experimentId,"N","S")
		connAdm.execute(strQuery)

		If experimentType = "5" then
			'if experiment is cust, check for CoAuthors, make them sign too
			if coAuthorSign = True then
				' the SAFE code will make a new PDF at revisionNumber + 1. Need to move it back to the current revisionNumber as coAuthorSigns reuse the same revision

				currentRevPath = session("SAFEPDFPath_" & state) '= uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber&"\"&folderName&"\sign.pdf"
				copyFromPath = session("SAFEPDFOutPath_" & state) '= uploadRoot&"\"&experimentUserId&"\"&experimentId&"\"&revisionNumber + 1&"\"&folderName&"\sign.pdf"

				set fs=Server.CreateObject("Scripting.FileSystemObject")
				' Make a backup of the current PDF
				fs.MoveFile currentRevPath,currentRevPath & getRandomString(10) & ".pdf"
				' Copy the new file back
				fs.MoveFile copyFromPath, currentRevPath

				a = addSignature(experimentId,experimentType,revisionNumber,session("userId"))
			else
				authors = getCoAuthors(experimentId, experimentType, revisionNumber)
				authorList = split(authors, ",")
				for each author in authorList
					if not isNull(author) AND author <> "" AND author > 0 then
						if checkIfAuthorSaved(author, experimentId, "5") then
							signers = addSigners(experimentId, "5", revisionNumber + 1, author)
						end if
					end if
				next

				'if experiment is cust, Update the experimentSignatures table
				a = addSignature(experimentId,experimentType,revisionNumber + 1,session("userId"))
			End if
		End if

		If witness then
			a = duplicateAndChangeStatus(experimentType,experimentId,"6",true)
			strQuery = "UPDATE witnessRequests SET accepted=1,dateWitnessed=GETUTCDATE(),dateWitnessedServer=GETDATE() WHERE requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S") & " AND experimentTypeId="&SQLClean(experimentType,"N","S")
			connAdm.execute(strQuery)
		Else
			if coAuthorSign = False then
				If isKeepOpen Then
					a = duplicateAndChangeStatus(experimentType,experimentId,"3",true)					
				else
					a = duplicateAndChangeStatus(experimentType,experimentId,"5",true)
				End if
			end if
		End If

		If experimentType = "4" then
			notExactlyExperimentType = "6"
		Else
			notExactlyExperimentType = experimentType + 1
		End if
		a = logAction(notExactlyExperimentType,experimentId,"",19)

		requesteeId = session("SAFERequestWitness_" & state) ' the var 'requesteeId' is used somewhere else in the coauthor stuff, if this line is at the top of the file, it doesn't work. ASP is great!
		If Not witness And requesteeId <> "0" then
			errorStr = requestWitness(experimentType,experimentId,requesteeId)
			title = "Witness Request"
			prefix = GetPrefix(experimentType)
			tableName = GetFullName(prefix, "experiments", true)
			page = GetExperimentPage(prefix)
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM " & tableName & " WHERE id="&SQLClean(experimentId,"N","S")
			rec.open strQuery,conn,3,3
			If Not rec.eof Then
				experimentName = rec("name")
			End if
			note = "The user "&session("firstName") & " " & session("lastName") & " has requested that you witness <a href=""" & page & "?id="&experimentId&""">"&experimentName&"</a>"

			a = sendNotification(requesteeId,title,note,7)
		End if
	End If
	%>
	<script type="text/javascript">
		window.location = '<%=pageName%>'
	</script>
	<%

End if


%>