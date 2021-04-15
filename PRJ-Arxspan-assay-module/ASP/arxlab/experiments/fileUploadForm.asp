<%'html holder for multi file upload form box on experiment pages%>
<div id="uploadFormHolderHolder" style="display:none;">
<div id="uploadFormHolder" style="display:none;">
<%If bCheck <> "IE 8.0" then%>
<link rel="stylesheet" href="/arxlab/jqfu/css/jquery-demo.css">
	<!--[if lte IE 8]>
	<link rel="stylesheet" href="/arxlab/jqfu/css/demo-ie8.css">
	<![endif]-->

<!-- CSS adjustments for browsers with JavaScript disabled -->
<noscript><link rel="stylesheet" href="/arxlab/jqfu/css/jquery.fileupload-noscript.css"></noscript>
<!-- #include virtual ="/arxlab/jqfu/jqfu.html" -->
<%End if%>
</div>
</div>