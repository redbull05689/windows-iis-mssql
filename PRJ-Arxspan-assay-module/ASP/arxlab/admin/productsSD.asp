<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%
sectionId = "tool"
subSectionId = "productsSD"
pageTitle = "Arxspan Products SD Download"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
If Not (session("roleNumber") = "1" And session("hasProductsSD") <> "0") Then
	response.redirect(loginScriptName)
End if
%>
<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->
<h1>Please wait</h1>
<%response.redirect(mainAppPath&"/admin/downloadProductsSD.asp")%>
<!--#include file="../_inclds/footer-tool.asp"-->
