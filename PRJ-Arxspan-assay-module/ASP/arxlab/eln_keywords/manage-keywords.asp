<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "manage-eln-keywords"
subsectionId = "manage-eln-keywords"
%>
<!-- #include file="../_inclds/globals.asp"-->

	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->
	<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
	<script type="text/javascript" src="js/manageKeywords.js"></script>

<%
If session("roleNumber") <= 1 Or session("canEditKeywords") Then
	canView = true
End if
If canView then
%>

<h1>Manage Keyword Dictionary</h1>
<br/>
<table class="experimentsTable keywordsTable">
<thead><tr><th>Keyword</th><th>Date Added</th><th>Disabled</th></tr></thead>
<tbody><tr><td colspan="3"><div class="addingKeywordTextInputContainer"><input type="text" placeholder="Keyword Text" id="addingKeywordTextInput" class="addingKeywordTextInput"><button class="newKeywordButton" type="button">Add New Keyword</button></div></td></tr>
<%
Call getConnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, displayText, dateAdded, disabled FROM keywords WHERE companyId="&SQLClean(session("companyId"),"N","S")&" ORDER BY id DESC"
rec.open strQuery,conn,3,3
If rec.eof Then
	%>
	<tr><td class="noKeywordsFound" colspan="3">No Keywords Found</td></tr>
	<%
End if
Do While Not rec.eof
%>
<tr keywordid="<%=rec("id")%>">
	<td>
		<div class="keywordValue"><%=rec("displayText")%></div>
	</td>
	<td>
		<div class="keywordDateAdded"><%=rec("dateAdded")%></div>
	</td>
	<td>
		<div class="keywordDisabledCheckboxContainer"><input type="checkbox" class="keywordDisabledCheckbox"<% If rec("disabled") Then %> checked<% End If %>></div>
	</td>
</tr>
<%
	rec.movenext
loop
%>
</table>
<%else%>
<p>Not Authorized</p>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->
<%
rec.close
Call disconnect
%>