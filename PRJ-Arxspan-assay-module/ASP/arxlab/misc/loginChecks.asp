<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<script type="text/javascript" src="<%=mainAppPath%>/js/acrobatCheck.js"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
Checking system requirements<br/>
<div style="visibility:hidden;">
<script type="text/javascript">
    hasChemdraw().then(function (isInstalled) {
        if (isInstalled) {
            cd_insertObject("text/xml", 2, 2, "test", "<%=mainAppPath%>/static/blank.cdx", false, true);
        }
    });
</script>
</div>
<script type="text/javascript">

function setCookie(c_name,value,exdays)
{
var exdate=new Date();
exdate.setDate(exdate.getDate() + exdays);
var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
document.cookie=c_name + "=" + c_value+";"+'path=/';
}

errors = false;
browser_info = perform_acrobat_detection();
if (browser_info.name)
{
	if(browser_info.acrobat_ver < 8)
	{
		document.write("Acrobat Reader out of date.  Switching to no pdf mode.<br>")
		getFile('<%=mainAppPath%>/ajax_doers/user_settings/switchToNoPdfMode.asp?rand='+Math.random());
		setCookie("acrobat","no",100)
		errors = true
	}
	else
	{
		setCookie("acrobat","yes",100)
	}
}
if (!errors)
{
	document.write("Your system meets all minimum system requirements.<br>")
}
</script>
<meta http-equiv="refresh" content="1; url=dashboard.asp">
<!-- #include file="../_inclds/footer-tool.asp"-->