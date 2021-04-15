<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage = true%>
<% Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<%data = request.form%>
<!-- #include virtual="/arxlab/_inclds/globals_apis.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include file="../fnc_makeRegApiCall.asp" -->
<%
response.write makeRegApiCall("getRegIdSuggestions_allFieldGroups/", data)
%>