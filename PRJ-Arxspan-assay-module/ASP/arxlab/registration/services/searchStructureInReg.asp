<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="../_inclds/lib_reg.asp"-->
<!-- #include file="../../accint/_inclds/fnc_getLocalRegNumber.asp"-->
<%
structure = request.Form("structure")

searchResults = getLocalRegNumber(structure, false)

set returnJson = JSON.parse("{}")
returnJson.set "localRegNumber", searchResults(1)

response.write(JSON.stringify(returnJson))
%>