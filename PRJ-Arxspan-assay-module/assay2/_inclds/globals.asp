<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
appServerIP = getCompanySpecificSingleAppConfigSetting("appServerIp", session("companyId"))
Response.ContentType = "text/html"
Response.AddHeader "Content-Type", "text/html;charset=UTF-8"
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<%
'Dim conn,connAdm
%>
<!-- #include file="../../_inclds/__whichServer.asp"-->
<!-- #include file="../../_inclds/misc/functions/fnc_getRandomString.asp"-->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->
<!-- #include file="../../_inclds/data_types/functions/fnc_removeDuplicates.asp"-->
<%
'restrict access
'accessible by users who are logged in
'internal IPs can access the system without authentication
If Not session("hasAssay") Or session("userId")="" Or session("assayRoleName")="" Then
	If request.servervariables("REMOTE_ADDR") <> "8.20.189.170" And request.servervariables("REMOTE_ADDR") <> "8.20.189.168" And request.servervariables("REMOTE_ADDR") <> "8.20.189.169" And request.servervariables("REMOTE_ADDR") <> "8.20.189.188" then
		response.redirect("/login.asp")
	End if
End if
%>
<%
'set internal IP of platform web service and upload path
uploadPath = uploadRootRoot
wsBase = "http://"&appServerIP&":5100"
%>