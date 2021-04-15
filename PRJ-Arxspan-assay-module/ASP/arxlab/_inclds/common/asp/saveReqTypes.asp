<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%
requestTypeNames = request.form("reqNames")
requestTypeIds = request.form("reqIds")

session("requestTypeNames") = requestTypeNames
session("requestTypeIds") = requestTypeIds

response.write(session("requestTypeNames"))
%>