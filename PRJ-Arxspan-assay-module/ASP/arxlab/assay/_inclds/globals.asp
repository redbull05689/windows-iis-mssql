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
<%
If Not session("hasAssay") Or session("userId")="" Or session("assayRoleName")="" Then
	If request.servervariables("REMOTE_ADDR") <> "8.20.189.170" And request.servervariables("REMOTE_ADDR") <> "8.20.189.168" And request.servervariables("REMOTE_ADDR") <> "8.20.189.169" And request.servervariables("REMOTE_ADDR") <> "8.20.189.188" then
		response.redirect("/login.asp")
	End if
End if
%>
<%
wsBase = "http://"&appServerIP&":5004"
uploadPath = uploadRootRoot
Select Case whichServer
	Case "DEV"
		wsBase = "https://"&appServerIP&":5005"
End select
%>
<%
If session("hasInv") Then
	wsBaseInv = "http://"&appServerIP&":5002"
End if
%>