<%
'displays chemistry
'this file is loaded in an iframe with parameters for width, height, and a name
'the name can be used by the platform to set or get the chemistry data from the plugin
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="_inclds/header-frame.asp"-->
<style type="text/css">
*{
	margin:0;
	padding:0;
	border:none;
}
</style>
<script type="text/javascript" src="../js/windowSize.js"></script>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript">
    hasChemdraw().then(function (isInstalled) {
        if (isInstalled) {
            cd_insertObject("text/xml", <%=request.querystring("w") %>, <%=request.querystring("h") %>, "<%=request.querystring("name")%>", "" <%if request.querystring("readonly") = "true" then %>, true <%else%>, false <% end if%>, true);
        }
    });
</script>
<!-- #include file="_inclds/footer-frame.asp"-->