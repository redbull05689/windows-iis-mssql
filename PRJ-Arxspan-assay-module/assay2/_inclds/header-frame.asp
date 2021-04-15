<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%'platform html header for iframe%>
<html>
<head>
<link href="css/styles-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="css/menu-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<link href="css/d3-css.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<script type="text/javascript" src="js/json2.js"></script>
<script type="text/javascript">
	connectionId = '<%=session("servicesConnectionId")%>';
</script>
</head>
<body style="background-color:#eee;">
