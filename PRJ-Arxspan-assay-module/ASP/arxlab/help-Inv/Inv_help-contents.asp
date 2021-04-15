<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%If session("userId") <> "" then%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>Contents</title>
<link href="css/styles-help.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
</head>
<body>

<div class="tableOfContents">
<h3><a href="Inv_help-content.asp?id=10" target="contentFrame">Inventory Overview</a></h3>
	
<h3><a href="Inv_help-content.asp?id=3" target="contentFrame">Logging In</a></h3>
	
<h3><a href="Inv_help-content.asp?id=9" target="contentFrame">Location Pane</a></h3>
	
<h3><a href="Inv_help-content.asp?id=1" target="contentFrame">Inventory Main Pane</a></h3>
	

<h3><a href="Inv_help-content.asp?id=4" target="contentFrame">Containers</a></h3>
	
<h3><a href="Inv_help-content.asp?id=5" target="contentFrame">Action Buttons</a></h3>
	
<h3><a href="Inv_help-content.asp?id=6" target="contentFrame">Audit Trail</a></h3>
	
<h3><a href="Inv_help-content.asp?id=11" target="contentFrame">Managing Locations</a></h3>

<h3><a href="Inv_help-content.asp?id=2" target="contentFrame">Creating a Container</a></h3>

<h3><a href="Inv_help-content.asp?id=7" target="contentFrame">Entering Container Contents</a></h3>

<h3><a href="Inv_help-content.asp?id=8" target="contentFrame">Bulk Operations</a></h3>

<h3><a href="Inv_help-content.asp?id=12" target="contentFrame">Other Bulk Operations</a></h3>

<h3><a href="Inv_help-content.asp?id=13" target="contentFrame">Search</a></h3>
	<ul>
		<li><a href="Inv_help-content.asp?id=13#search-types" target="contentFrame">Text Search</a></li>
		<li><a href="Inv_help-content.asp?id=13#search-types" target="contentFrame">Advanced Search</a></li>
		<li><a href="Inv_help-content.asp?id=13#search-types" target="contentFrame">Chemical Search</a></li>
	</ul>
<h3><a href="Inv_help-content.asp?id=14" target="contentFrame">Receiving New Containers</a></h3>	

</div>
</body>
</html>
<%End if%>