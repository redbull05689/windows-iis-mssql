<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%if session("userId") = "2" then%>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
<script type="text/javascript">
    hasChemdraw().then(function (isInstalled) {
        if (isInstalled) {
            cd_insertObject("text/xml", 860, 300, "mycdx", "getCDX.asp?id=12784&random=" + Math.random(), false, true);
        }
    });
</script>
<%end if%>