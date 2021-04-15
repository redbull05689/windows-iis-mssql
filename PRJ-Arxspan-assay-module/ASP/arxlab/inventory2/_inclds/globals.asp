<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'Dim conn,connAdm
%>
<!-- #include file="../../_inclds/__whichServer.asp"-->
<!-- #include file="../../_inclds/misc/functions/fnc_getRandomString.asp"-->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->
<!-- #include file="../../_inclds/data_types/functions/fnc_removeDuplicates.asp"-->
<!-- #include file="../../_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
appServerIP = getCompanySpecificSingleAppConfigSetting("appServerIp", session("companyId"))
If Not isApiPage Then
    If Not session("hasInv") Or session("userId")="" Or session("invRoleName")="" Then
        If request.servervariables("REMOTE_ADDR") <> "8.20.189.170" And request.servervariables("REMOTE_ADDR") <> "8.20.189.168" And request.servervariables("REMOTE_ADDR") <> "8.20.189.169" And request.servervariables("REMOTE_ADDR") <> "8.20.189.188" And request.servervariables("REMOTE_ADDR") <> "8.20.189.21" And request.servervariables("REMOTE_ADDR") <> "8.20.189.141" And request.servervariables("REMOTE_ADDR") <> "8.20.189.142" then
            response.redirect("/login.asp")
        End if
    End if
End If
%>
<%
uploadPath = uploadRootRoot

' Helper function to get the inventory API IP address.
function getInvIp()
    appServerIp = getDefaultSingleAppConfigSetting("appServerIp")
    getInvIp = "http://"&appServerIp&":5002"
end function

' Maintained for legacy purposes.
wsBase = getInvIp()
%>