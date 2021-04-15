<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="error"%>
<!-- #include file="../_inclds/globals.asp"-->

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<div class="registrationPage">

<%
	titleText = request.querystring("title")
	messageText = request.querystring("message")
	'titleText =  SQLClean(titleText,"T","S")
	'messageText =  SQLClean(messageText,"T","S")
%>
<h1><%=titleText %></h1>
<p><%=messageText%></p>
</div>

<!-- #include file="../_inclds/footer-tool.asp"-->