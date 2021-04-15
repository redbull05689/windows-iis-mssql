<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function logAction(extraType,extraId,extraText,actionId)
	'insert an item into the logs table
	'extratype is stuff like notebook experiment etc
	'extraid is an id
	'extratype/id are used to make links like a link to the experiment in the ui for the logs
	
	logTableName = getLogTableName()
	Call getconnectedlog
	logUserId = session("userId")
	logCompanyId = session("companyId")
	If logUserId = "" Then
		logUserId = 0
	End If
	If logCompanyId = "" Then
		logCompanyId = 0
	End if	
	'insert data into logs table with time and ip
	logStrQuery = "insert into "&logTableName&"(userId,dateSubmitted,dateSubmittedServer,companyId,extraTypeId,extraId,extraText,actionId,ip,sessionId,pageName,hungSaveSerial) values(" &_
	SQLClean(logUserId,"N","S") & ","
	logStrQuery = logStrQuery & "GETUTCDATE(),GETDATE(),"
	logStrQuery = logStrQuery & SQLClean(logCompanyId,"N","S") & "," &_
	SQLClean(extraType,"N","S") & "," &_
	SQLClean(extraId,"N","S") & "," &_
	SQLClean(extraText,"T","S") & "," &_
	SQLClean(actionId,"N","S") & "," &_
	SQLClean(request.servervariables("REMOTE_ADDR"),"T","S") & "," &_
	SQLClean(session.sessionId,"T","S") & "," &_
	SQLClean(Mid(Request.ServerVariables("SCRIPT_NAME"),1,190),"T","S")&","&_
	SQLClean(hungSaveSerial,"T","S")&")"
	connLog.execute(logStrQuery)
	logAction = True
	Call disconnectlog
end function
%>