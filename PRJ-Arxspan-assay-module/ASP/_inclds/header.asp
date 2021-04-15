<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If request.querystring("source")<>"compounds" then
	Set browserdetect = Server.CreateObject("MSWC.BrowserType")
	browser=browserdetect.Browser
	version=browserdetect.Version
	bCheck = browser&" "&version
End if
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title><%=pageTitle%></title>
	<meta name="keywords" content="<%=metaKey%>" />
	<meta name="description" content="<%=metaD%>" />

<link href="/css/loginpage.css" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="/css/bootstrap.min.css" rel="stylesheet" type="text/css" MEDIA="screen">

<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
<meta name="keywords" content="<%=metaKey%>" />
<meta name="description" content="<%=metaD%>" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />

<script type="text/javascript"><!--//--><![CDATA[//><!--
sfHover = function() 
	{
	var sfEls = document.getElementById("nav").getElementsByTagName("LI");

	for (var i=0; i<sfEls.length; i++) 
		{

		sfEls[i].onmouseover=function() 
			{
			this.className+=" sfhover";
			}

		sfEls[i].onmouseout=function() 
			{
			this.className=this.className.replace(new RegExp(" sfhover\\b"), "");
			}
		}
	}
if (window.attachEvent) window.attachEvent("onload", sfHover);
//--><!]]></script>

<!--[if IE 6]>
<script src="/js/DD_belatedPNG.js"></script>
<script>
  /* EXAMPLE */
  DD_belatedPNG.fix('.homeLogin');
  DD_belatedPNG.fix('.png');
  
  /* string argument can be any CSS selector */
  /* change it to what suits you! */
</script>
<![endif]--> 

<!--[if (gte IE 6)&(lt IE 8)]>
<style type="text/css">
.pageNav li  {
	margin-left:8px;
	list-style:none;
	line-height:12px;
	height:12px;
	}
</style>
<![endif]-->


</head>

<body>
