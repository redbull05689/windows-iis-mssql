<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If session("useGMT") Then
	set timeRec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT GETUTCDATE() as theDate"
	timeRec.open strQuery,connAdm,0,-1
	If Not timeRec.eof Then
		theDate = timeRec("theDate")&" (GMT)"
	Else
		theDate = ""
	End If
	
	timeRec.close
	set timeRec = Nothing
Else
	theDate = Date() & " " & Time() &" (EST)"
End If

prefix = GetPrefix(experimentType)
sTableName = GetFullName(prefix, "experimentHistoryView", true)

Set signRec = server.CreateObject("ADODB.RecordSet")
if experimentType <> "5" then 
	strQuerySign = "SELECT * FROM "&sTableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND revisionNumber="&SQLClean(revisionNumber,"N","S")
else
	strQuerySign = "SELECT u.firstName, u.lastName, e.userId as userId, u.email, e.dateSigned AS dateSubmitted, e.dateSignedServer AS dateSubmittedServer FROM experimentSignatures e JOIN users u ON e.userId=u.id JOIN " & sTableName & " t ON t.experimentId = e.experimentId WHERE e.experimentId = " & SQLClean(experimentId,"N","S") & " AND t.revisionNumber=" & SQLClean(revisionNumber,"N","S") & " AND e.experimentType = " & SQLClean(experimentType, "N", "S") & " AND e.revisionNumber=" & SQLClean(revisionNumber,"N","S") & " AND signed=1"
end if
signRec.open strQuerySign,connAdm,0,-1

signTablel = ""
If Not signRec.eof Then
	signTable = "<table width='250'>"
	If expRec("statusId") = 10 or expRec("statusId") = 11 Then
		signTable = signTable & "<tr><td style='font-weight:bold;font-size:18px;' colspan='2'>Not Pursued Information</td></tr>"
	else
		signTable = signTable & "<tr><td style='font-weight:bold;font-size:18px;' colspan='2'>Signer Information</td></tr>"
	end if
	
	firstRow = true
	do while not signRec.eof
		If session("useGMT") Then
			theDate = signRec("dateSubmitted")&" (GMT)"
		Else
			theDate = signRec("dateSubmittedServer")&" (EST)"
		End if
		if counter = 0 then
			firstRow = false
			signTable = signTable & "<tr></tr>"
		end if
		signTable = signTable & "<tr><td style='font-weight:bold;'>Name</td><td>"&signRec("firstName") & " " & signRec("lastName")&"</td></tr>"
		signTable = signTable & "<tr><td style='font-weight:bold;'>User Id</td><td>"&signRec("userId")&"</td></tr>"
		signTable = signTable & "<tr><td style='font-weight:bold;'>Email</td><td>"&signRec("email")&"</td></tr>"
		signTable = signTable & "<tr><td style='font-weight:bold;'>Date Signed</td><td>"&theDate&"</td></tr></table><br><table width='250'>"
		signRec.movenext
	loop
	signTable = signTable & "</table>"
End If

signRec.close()
Set signRec = Nothing
%>