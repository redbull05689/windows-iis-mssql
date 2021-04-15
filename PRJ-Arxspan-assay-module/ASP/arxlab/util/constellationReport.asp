<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<%if session("companyId") = "1" then
	logViewName = getDefaultSingleAppConfigSetting("logViewName")
	response.contenttype="text/CSV"
	response.addheader "ContentType","text/CSV"
	Response.addheader "Content-Disposition", "attachment; " & "filename=constellation_report.csv"
	
	response.write("user,last login,number of experiments,enabled"&vbcrlf)

	Call getconnected
	Call getconnectedlog
	Set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT * FROM users WHERE companyId=9"
	rec.open strQuery,conn,3,3
	Do While Not rec.eof
		firstName=rec("firstName")
		lastName=rec("lastName")
		numExperiments = 0
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT count(*) as myCount FROM experiments WHERE userId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,conn,3,3
		numExperiments = numExperiments + rec2("myCount")
		rec2.close
		strQuery = "SELECT count(*) as myCount FROM bioExperiments WHERE userId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,conn,3,3
		numExperiments = numExperiments + rec2("myCount")
		rec2.close
		strQuery = "SELECT count(*) as myCount FROM freeExperiments WHERE userId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,conn,3,3
		numExperiments = numExperiments + rec2("myCount")
		rec2.close
		strQuery = "SELECT count(*) as myCount FROM analExperiments WHERE userId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,conn,3,3
		numExperiments = numExperiments + rec2("myCount")
		rec2.close
		theDate = "Never"
		Set rec3 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM "&logViewName&" WHERE userId="&SQLClean(rec("id"),"N","S")& " order by dateSubmitted desc"
		rec3.open strQuery,connlog,3,3
		If Not rec3.eof Then
			theDate = rec3("dateSubmitted")
		End If
		If rec("enabled") = 1 Then
			en = "yes"
		Else
			en = "no"
		End if
		response.write(firstName&" "&lastName&","&theDate&","&numExperiments&","&en&vbcrlf)
		rec.movenext
	Loop
	rec.close
	Set rec = nothing
	Call disconnect
	Call disconnectlog
end if%>