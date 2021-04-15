<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
mailServerAddress = getCompanySpecificSingleAppConfigSetting("mailServerAddress", session("companyId"))
globalSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("globalSupportEmailAddress", session("companyId"))
sectionId = "hungSave"%>
<!-- #include file="../../../_inclds/globals.asp" -->
<%
'this page is queried after a two sent intervals during the experiment save.  The first sets firstTimeout to 1 the second sets secondTimeout to 1
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id from hungExperiments WHERE serial="&SQLClean(request.Form("hungSaveSerial"),"T","S")&" AND firstTimeout=0"
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	strQuery = "UPDATE hungExperiments SET firstTimeout=1 WHERE serial="&SQLClean(request.Form("hungSaveSerial"),"T","S")
	connAdm.execute(strQuery)
Else
	strQuery = "UPDATE hungExperiments SET secondTimeout=1 WHERE serial="&SQLClean(request.Form("hungSaveSerial"),"T","S")
	connAdm.execute(strQuery)
End if
Call disconnectadm

'set mailObj = Server.CreateObject("CDO.Message")
''mailObj.Host = mailServerAddress ' Required
'mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
'mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = mailServerAddress
'mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
'mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = False
'mailObj.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
'mailObj.Configuration.Fields.Update
'mailObj.From = globalSupportEmailAddress
'mailObj.To = "support@arxspan.com"
'mailObj.Subject = "Arxspan Support: possibly hung save (taking longer than 10 seconds)"
'bodyText = "experiment id: "&request.Form("hungSaveExperimentId")&vbcrlf
'bodyText = bodyText & "user: "&request.Form("hungSaveUserName")&vbcrlf
'bodyText = bodyText & "company: "&request.Form("hungSaveCompanyName")&vbcrlf
'bodyText = bodyText & "session id from session: "&session("userId")&vbcrlf
'bodyText = bodyText & "revision: "&request.Form("hungSaveRevisionId")& " (if the saved worked then the maximum revision will be one higher than this)"&vbcrlf&vbcrlf
'bodyText = bodyText & request.Form("hungSaveFrameHTML")
'mailObj.textBody = bodyText
'mailObj.Send
%>