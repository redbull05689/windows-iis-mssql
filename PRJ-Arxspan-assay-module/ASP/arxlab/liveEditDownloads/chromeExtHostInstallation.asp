<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
subSectionId = "chromeExtHostInstallation"
%>
<!-- #include file="../_inclds/globals.asp" -->

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link rel="stylesheet" href="/arxlab/liveEditDownloads/jquery-ui.css">
<style>
a.btn {
  background: #3498db;
  background-image: -webkit-linear-gradient(top, #3498db, #2980b9);
  background-image: -moz-linear-gradient(top, #3498db, #2980b9);
  background-image: -ms-linear-gradient(top, #3498db, #2980b9);
  background-image: -o-linear-gradient(top, #3498db, #2980b9);
  background-image: linear-gradient(to bottom, #3498db, #2980b9);
  -webkit-border-radius: 6;
  -moz-border-radius: 6;
  border-radius: 6px;
  text-shadow: 1px 1px 3px #666666;
  font-family: Arial;
  color: #ffffff;
  font-size: 20px;
  background: #1EB242;
  padding: 10px 20px 10px 20px;
  border: solid #b8b8b8 1px;
  text-decoration: none;
}

a.btn:hover {
  background: #05c960;
  background-image: -webkit-linear-gradient(top, #05c960, #66b069);
  background-image: -moz-linear-gradient(top, #05c960, #66b069);
  background-image: -ms-linear-gradient(top, #05c960, #66b069);
  background-image: -o-linear-gradient(top, #05c960, #66b069);
  background-image: linear-gradient(to bottom, #05c960, #66b069);
  text-decoration: none;
  color: #ffffff;
}
</style>
<script type="text/javascript">
//function install (aEvent)
//{
//	for (var a = aEvent.target; a.href === undefined;) a = a.parentNode;
//	var params = {
//		"Foo": { URL: aEvent.target.href,
//		toString: function () { return this.URL; }
//		}
//	};
//  
//    if ("InstallTrigger" in window){
//		// Gecko platform, InstallTrigger available
//		InstallTrigger.install(params);
//	}
//	else{
//		swal("Extension installation error","Please use Mozilla FireFox browser to install the extension","error")
//	}
//    return false;
}
</script>

<%
If session("companyId") <> "" Then 
%>
<table width="100%">
<tr>
<td valign="top">
	<div  class="dashboardObjectContainer liveInstall elnDashObj" style="width:100%;">
		<div class="objHeader elnHead"><h2>Live Edit Installation</h2></div>


<script type="text/javascript">
	$(function() {
		$("#accordion > div").accordion({ header: "h3", collapsible: true, active: false });

		//Show the best options for the current user
		if (navigator.platform.indexOf('Mac') > -1){
			$("#MacHost a").click();
		}else if (navigator.platform.indexOf('Win') > -1){
			$("#WinHost a").click();
		}

		if(navigator.userAgent.indexOf("Edge") != -1 ) //Need to check edge first, because the edge user agent has "Chrome" in it
		{
			$("#EdgeExt a").click(); 
		}  
		else if(navigator.userAgent.indexOf("Chrome") != -1 )
		{
			$("#ChromeExt a").click();
		}
		else if(navigator.userAgent.indexOf("Firefox") != -1 ) 
		{
			$("#FFExt a").click();
		}
	})
</script>
<div class="objBody">
<p>To allow your computer to support Live Edit in the ELN, please download and install the following two items:</p>
<ul>
    <li>The <strong>Native Host</strong> for your computer's operating system.</li>
    <li>The <strong>Browser Extension</strong> for the browser that you will be using.</li>
</ul>
<p>Contact Arxspan Support at <a href="/arxlab/support-request.asp" >support@arxspan.com</a> if you have questions or need further assistance regarding installation of these features.</p>
<br />
<div id="accordion">
	<h1>Native Host</h1>
	<hr />
    <div id="WinHost">
        <h3><a href="#">Microsoft Windows PC</a></h3>
        <div>
			<p>Download the Arxspan Live Edit Windows Host.</p>
			<a class="btn" href="<%=mainAppPath%>/liveEditDownloads/downloads/LiveEditHost211Installer.exe">Live Edit Windows Host</a>
		</div>
    </div>
	<div id="MacHost">
        <h3><a href="#">Apple MacOS</a></h3>
        <div>
			<p>Download the Arxspan Live Edit MacOS Host.</p>
			<a class="btn" href="<%=mainAppPath%>/liveEditDownloads/downloads/LiveEditHost211InstallerMac.pkg">Live Edit MacOS Host</a>
		</div>
    </div>
	<br />
	<h1>Browser Extension</h1>
	<hr />
    <div id="ChromeExt">
        <h3><a href="#">Google Chrome</a></h3>
		<div>
			<p>Download the Arxspan Live Edit Google Chrome Extension from the Chrome Web Store.</p>
        	<a class="btn" target="_blank" href="https://chrome.google.com/webstore/detail/arxspan-live-edit-extensi/npdpblkmffacjgfjdneaadfehnekbdfk">Chrome Extension</a>
		</div>
    </div>
    <div id="FFExt">
        <h3><a href="#">Mozila Firefox</a></h3>
        <div>Coming Soon! <br \>Please use Google Chrome for now.</div>
    </div>
	<div id="EdgeExt">
        <h3><a href="#">Microsoft Edge</a></h3>
        <div>Coming Soon! <br \>Please use Google Chrome for now.</div>
    </div>
</div>

</td>
</tr>
</table>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->