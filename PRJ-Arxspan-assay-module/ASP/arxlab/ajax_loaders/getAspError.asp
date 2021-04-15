<!-- #include virtual="/_inclds/sessionInit.asp" -->

<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
aspErrorPath = getCompanySpecificSingleAppConfigSetting("aspErrorPath", session("companyId"))
if session("companyId") = "1" then%>
<%
set fs=Server.CreateObject("Scripting.FileSystemObject")
Set TextStream = fs.OpenTextFile(aspErrorPath&"\arx"&request.querystring("id")&".html", 1, False, -2)
html = TextStream.ReadAll
TextStream.close
Set TextStream = nothing
response.write(html)
%>
<%end if%>