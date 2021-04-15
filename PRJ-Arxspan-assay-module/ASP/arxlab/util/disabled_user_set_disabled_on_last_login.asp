<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId = "test"%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
if session("userId") = "2" And 1=2 then
	logViewName = getDefaultSingleAppConfigSetting("logViewName")
	logTableName = getLogTableName()
	call getconnected
	Call getconnectedlog
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery  = "SELECT * FROM users"
	rec.open strQuery,conn,3,3
	Do While Not rec.eof
		If rec("enabled") = 0 Then
			Set rec2 = server.CreateObject("ADODB.Recordset")
			strQuery = "select logV.lastLoginDate,logV2.ip,userV.* from (SELECT userId,MAX(dateSubmitted) as lastLoginDate from [LOGS].dbo."&logViewName&" WHERE actionId=10 group by userID) logV inner join (SELECT ip,dateSubmitted,userId as uid2 from [LOGS].dbo."&logViewName&") logV2 on logV.userId = logV2.uid2 and logV2.dateSubmitted = logV.lastLoginDate inner join usersView userV on userV.id = logV.userId WHERE  userId="&SQLClean(rec("id"),"N","S")
			rec2.open strQuery,conn,3,3
			If Not rec2.eof Then
				disabledDate = rec2("lastLoginDate")
			Else
				disabledDate = rec("dateOfSignup")
			End if

			logStrQuery = "insert into "&logTableName&"(userId,dateSubmitted,dateSubmittedServer,companyId,extraTypeId,extraId,extraText,actionId,ip,sessionId,pageName,hungSaveSerial) values(" &_
				SQLClean(session("userId"),"N","S") & ","&_
				SQLClean(disabledDate,"T","S") & ","&_
				SQLClean(disabledDate,"T","S") & ","&_
				SQLClean(session("companyId"),"N","S") & "," &_
				SQLClean("0","N","S") & "," &_
				SQLClean(rec("id"),"N","S") & "," &_
				SQLClean("","T","S") & "," &_
				SQLClean("23","N","S") & "," &_
				SQLClean(request.servervariables("REMOTE_ADDR"),"T","S") & "," &_
				SQLClean(session.sessionId,"T","S") & "," &_
				SQLClean("","T","S")&","&_
				SQLClean(hungSaveSerial,"T","S")&")"
				connLog.execute(logStrQuery)

		End if
		rec.movenext
	Loop
	rec.close
	Set rec = nothing
	call disconnect
	Call disconnectlog
end If
%>