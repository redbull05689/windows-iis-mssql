<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<!-- #include file="_inclds/fnc_getLocalRegNumber.asp"-->
<!-- #include file="_inclds/fnc_searchStructureInReg.asp"-->

<%
structure = request.Form("structure")

searchResults = searchStructureInReg(structure)

response.write(searchResults)
%>