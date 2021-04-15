<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=True%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/uploadInit.asp"-->
<html>
<head>
<script type="text/javascript">
<!-- #include file="../_inclds/common/js/uploadJS.asp"-->
</script>
</head>
<body>
<%
formName = request.querystring("formName")
%>
<form action="upload-file.asp?<% = PID %>&formName=<%=formName%>&random=<%=rnd%>" method="post" ENCTYPE="multipart/form-data" OnSubmit="unsavedChanges=false;return preUpload('<%=formName&"_file"%>');">
	<input type="file" name="<%=formName%>_file" id="<%=formName%>_file" style="width:200px;">
	<input type="submit" value="Upload">
</form>
</body>
</html>