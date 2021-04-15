<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%'should probably add globals to this file.  Also make email addresses global configs%>
<%If session("userId") <> "" then%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Help</title>
<link href="css/styles-help.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
</head>
<body>
<div class="containerDiv background">
<div class="topDiv"><img src="images/help-logo.gif" width="150" height="37"></div>

<% 
Dim theID,theIndex
theID = "inv_help-content.asp?id="& request.querystring("id")
theIndex = "inv_help-contents.asp"
%>



<iframe src="<%=theIndex %>" width="30%" height="400" style="float:left;display:inline;" class="frameStyle">
</iframe>
<iframe  name="contentFrame" src="<%=theID %>" width="70%" height="400" style="float:right;display:inline;" class="frameStyle">
  <p>Your browser does not support iframes.</p>
</iframe>





<div class="footerDiv"><div style="float:left;"><a href="mailto:support@arxspan.com">Contact</a> Arxspan support.</div>
&copy;<%=year(now())%> Arxspan, Inc. All rights reserved.

</div>
</div>
</body>
</html>
<%End if%>