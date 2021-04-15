<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
    sectionId = "tool"
    subSectionId = "savedSearchQueries"
    pageTitle = "Arxspan Saved Search Queries"

    If session("email") <> "support@arxspan.com" Then
        response.redirect(loginScriptName)
    End if
%>

<!--#include file="../_inclds/header-tool.asp"-->
<!--#include file="../_inclds/nav_tool.asp"-->

<iframe src="/node/savedSearchQueryTable"></iframe>

<!--#include file="../_inclds/footer-tool.asp"-->