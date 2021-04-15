<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title><%=pageTitle%></title>
	<meta name="keywords" content="<%=metaKey%>" />
	<meta name="description" content="<%=metaD%>" />
<!-- new ft stuff-->
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/arxspan_global_styles.css?<%=jsRev%>">
<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/transitionStyles.css?<%=jsRev%>">
<link href="<%=mainCSSPath%>/latofont.css" rel="stylesheet" type="text/css">
<script src="<%=mainAppPath%>/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/arxlayout.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/select2-3.5.1/select2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/isotope.pkgd.min.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.placeholder.js?<%=jsRev%>"></script>
<!--[if lte IE 8]>
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/css/normalize.css" />
 <script type="text/javascript" src="<%=mainAppPath%>/js/html5shiv-printshiv.min.js"></script>
 <script type="text/javascript" src="<%=mainAppPath%>/js/jspatch.js"></script>
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/css/ie8_and_below.css" />
	<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/css/lato_ie_300.css" /> 
 <link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/css/lato_ie_400.css" /> 
	<link rel="stylesheet" type="text/css" href="<%=mainCSSPath%>/css/lato_ie_700.css" />
<![endif]-->
<!-- end new ft stuff-->

<link href="<%=mainCSSPath%>/style-print.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="print">
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link href="<%=mainCSSPath%>/styles-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="<%=mainCSSPath%>/menu-tool.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<link href="<%=mainCSSPath%>/cms.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">
<link href="<%=mainCSSPath%>/popup_styles.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link href="<%=mainCSSPath%>/arxspan_advanced_search_red.css?<%=jsRev%>" rel="stylesheet" type="text/css">
<link href="<%=mainCSSPath%>/reg-styles.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">

<%If InStr(LCase(request.servervariables("HTTP_USER_AGENT")),"safari") = 0 or InStr(LCase(request.servervariables("HTTP_USER_AGENT")),"chrome") <> 0 then%>
<style type="text/css">
.experimentsTable TR:hover {
	background-color:#F5F5F5;
	}
</style>
<%End if%>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1"/>

<meta name="keywords" content="<%=metaKey%>" />
<meta name="description" content="<%=metaD%>" />

<script type="text/javascript" src="<%=mainAppPath%>/js/getFile2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/popups.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/ajax.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/dateFormat.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/showBigProd.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/ajaxPostToFile.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/common/dateFunctions.js?<%=jsRev%>"></script>

<%If isRegSearch then%>
<script src="<%=mainAppPath%>/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
<style type="text/css">
div.regSearchForm{
	width:100%;
}
</style>
<%End if%>

<script  type="text/javascript" language="JavaScript1.2">
var popUpWin=0;
function helpPopup(URLStr, winName, width, height)
{
  if(popUpWin)
  {
    if(!popUpWin.closed) popUpWin.close();
  }
  popUpWin = open('<%=mainAppPath%>/'+URLStr, winName, 'scrollbars=0,toolbar=0,status=0,directories=no,menubar=0,resizable=yes,width='+width+',height='+height+'');
}
</script>



<script type="text/javascript"><!--//--><![CDATA[//><!--
//--><!]]></script>

<!--[if IE 6]>
<script src="js/DD_belatedPNG.js"></script>
<script>
  /* EXAMPLE */
  DD_belatedPNG.fix('#homeContent');
  DD_belatedPNG.fix('#innerContent');
  DD_belatedPNG.fix('.homeBannerText H1');
  
  /* string argument can be any CSS selector */
  /* change it to what suits you! */
</script>
<![endif]--> 

<script type="text/javascript">
function resizeIFrame(iframeID) {
	if(self==parent)
		return false;
		
<%if (not inApiFrame) And (not dontResize) then%>
	var theIframe = parent.document.getElementById(iframeID);
	if(theIframe)
	{
		iFrameWidth  = theIframe.contentWindow.document.body.scrollWidth;
		iFrameHeight = theIframe.contentWindow.document.body.scrollHeight;
		theIframe.style.height = iFrameHeight+'px';
	}
<%end if%>
}
</script>

</head>

<body id="framePage" <%if not dontResize then%>onload="resizeIFrame(window.name)"<%End if%> style="background-color:<%If request.querystring("frameBG") <> "" then%><%=request.querystring("frameBG")%><%else%>#DFDFDF<%End if%>;padding:;<%If request.querystring("frameWidth") <> "" Then%>width:<%=request.querystring("frameWidth")%>px;<%End if%>">

<%If request.querystring("frameExperimentTableWidth")<>"" then%>
<style type="text/css">
	.experimentsTable{
		width: <%=request.querystring("frameExperimentTableWidth")%>px !important;
	}
</style>
<%End if%>