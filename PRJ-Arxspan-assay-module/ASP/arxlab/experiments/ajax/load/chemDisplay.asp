<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentType = request.querystring("experimentType")
attachmentId = request.querystring("id")
pre = request.querystring("pre")
historyFlag = request.querystring("history")
%>
<html>
<head>
<!-- #include virtual="/arxlab/js/common/chemdraw.asp"-->
</head>
<body>

<script type="text/javascript">
    hasChemdraw().then(function (isInstalled) {
        if (isInstalled) {
            cd_insertObject("text/xml", 760, 300, "mycdx", "<%=mainAppPath%>/getSourceFile.asp?id=<%=attachmentId%>&experimentType=<%=experimentType%>&pre=<%=pre%>&history=<%=historyFlag%>", true, true);
        }
    });
</script>

</body>
</html>