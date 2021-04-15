<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="../_inclds/lib_reg.asp"-->
<!-- #include file="../../accint/_inclds/fnc_searchAccordStructures.asp"-->

<%
structure = request.Form("structure")

searchResults = searchAccordStructures(structure)

response.write(searchResults)
%>