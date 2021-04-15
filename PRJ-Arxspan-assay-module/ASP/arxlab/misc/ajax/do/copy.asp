<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
If request.Form("linkType") <> "" Then
	session("linkType") = request.Form("linkType")
End If
If request.Form("linkId") <> "" Then
	session("linkId") = request.Form("linkId")
End if
%>
<div id="resultsDiv">success</div>