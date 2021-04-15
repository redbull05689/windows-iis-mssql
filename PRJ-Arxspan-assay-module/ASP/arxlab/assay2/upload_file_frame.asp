<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<script language="JScript" src="/arxlab/js/json2.asp" runat="server"></script>

<script type="text/javascript" src="<%=mainAppPath%>/jqfu/js/jquery-1.10.2.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/jqfu/jquery-ui-1.10.3/ui/minified/jquery-ui.min.js?<%=jsRev%>"></script>
<!-- The Iframe Transport is required for browsers without support for XHR file uploads -->
<script type="text/javascript" src="<%=mainAppPath%>/jqfu/js/jquery.iframe-transport.js?<%=jsRev%>"></script>
<!-- The basic File Upload plugin -->
<script type="text/javascript" src="<%=mainAppPath%>/jqfu/js/jquery.fileupload.js?<%=jsRev%>"></script>

<%
function canDisplayInBrowser(fn)
	'for attachments.  Checks whether attachment can be displayed in an image tag
	isExt = Replace(lcase(getFileExtension(fn)),".","")
	if isExt = "jpg" or isExt = "jpeg" or isExt = "gif" or isExt = "bmp" or isExt = "png" then
		canDisplayInBrowser = true
	else
		canDisplayInBrowser = false
	end if
end function
%>

<html>
<head>
<style type="text/css">
*{
	font-family:Arial, Helvetica, sans-serif;
}
</style>
<script type="text/javascript" src="../js/windowSize.js"></script>
<%
'required for the upload progress bar
Set UploadProgress = Server.CreateObject("Persits.UploadProgress")
PID = "PID=" & UploadProgress.CreateProgressID()
barref = "/arxlab/static/framebar.asp?to=10&" & PID
%>
<script type="text/javascript">
function resizeIframe(imageId,iframeId){
	if(document.getElementById(imageId).style.display=="block"){
		w = document.getElementById(imageId).clientWidth;
		if (w > 800){
			document.getElementById(imageId).style.width = "800px";
		}
		h = document.getElementById(imageId).clientHeight;
		if (h > 800){
			document.getElementById(imageId).style.height = "800px";
		}
		w = document.getElementById(imageId).clientWidth;
		h = document.getElementById(imageId).clientHeight;
		window.parent.document.getElementById(iframeId).style.width =  (w+30)+"px";
		window.parent.document.getElementById(iframeId).style.height =  (h+120)+"px";
		iframeResized = true;
	}else{
		window.parent.document.getElementById(iframeId).style.width =  window.parent.document.getElementById(iframeId).width;
		window.parent.document.getElementById(iframeId).style.height =  window.parent.document.getElementById(iframeId).height;
	}

}

function showProgress()
{
	strAppVersion = navigator.appVersion;
	el = document.getElementById("file")
	if (el.value != ""){
		if (strAppVersion.indexOf('MSIE') != -1 && strAppVersion.substr(strAppVersion.indexOf('MSIE')+5,1) > 4){
			winstyle = "dialogWidth=385px; dialogHeight:140px; center:yes";
			window.showModelessDialog('<% = barref %>&b=IE',null,winstyle);
		}else{
			window.open('<% = barref %>&b=NN','','width=375,height=115', true);
		}
	}else{
		alert("Please enter a file")
		return false;
	}
}
</script>
</head>
<body id ="upload-file-zone" ondragover="dragFileOver(event);"  ondragleave ="dropFileLeave(event);">
<%
fileId = request.querystring("fileId")
%>

<%If fileId <> "" then%>
	<%
	Set D = JSON.parse("{}")
	D.Set "id",fileId
	D.Set "connectionId", session("servicesConnectionId")
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056
	http.open "POST",wsBase&"/loadForm/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(JSON.stringify(D))
	http.send JSON.stringify(D)
	http.waitForResponse(60)
	Set r = JSON.parse(http.responseText)

	If r <> "" Then
		Set r = r.Get("form")
		filename = r.Get("actualFilename")
		
		fileExtension = r.Get("fileExtension")
		displayFilename = r.Get("filename")
	%>
		<h3 style='margin-top:0px;margin-bottom:2px;'><%=displayFilename%></h3>
		<a href="<%If fileId="" then%>javascript:void(0);<%else%>getSourceFile.asp?fileId=<%=fileId%>&collection=<%=collection%>&connectionId=<%=session("servicesConnectionId")%><%End if%>" id="<%=fileId%>_download_button" class="littleButton" style="color:#333;<%If fileId="" then%>display:none;<%End if%>">Download</a>

		<a href="javascript:void(0);" onclick="window.parent.modal.open({content:'<img src=\'getImage.asp?fileId=<%=fileId%>\'>'})" id="<%=fileId%>_img_show" style="color:#333;margin-left:10px;<%If fileId="" Or not canDisplayInBrowser(filename) then%>display:none;<%End if%>">Show Image</a>
		<div style="height:10px;"></div>
	<%End if%>
<%End if%>

<%If request.querystring("readOnly") <> "true" then%>
<div id ="upload-file-assay" style="display: none"></div>
<form  style='margin-bottom:0px;' action="upload-file.asp?<% = PID %>&formId=<%=formId%>&fieldId=<%=fieldId%>&random=<%=rnd%>&connectionId=<%=session("servicesConnectionId")%>" method="post" ENCTYPE="multipart/form-data" OnSubmit="return showProgress();">
	<input type="file" name="file" id="file">
	<input type="submit" <%If fileId="" then%>value="Upload"<%else%>Value="Reupload"<%End if%>>
</form>
<%End if%>
<p style="display:none;">drag your file here for uploading</p>
<input type="text" value="<%=fileId%>" id="theFileId" style="display:none;">
</body>
<script type="text/javascript">

function dragFileOver(ev) {
    ev.preventDefault();
    document.getElementById("upload-file-zone").setAttribute("style","background-color: grey")
}

function dropFileLeave(ev){
    ev.preventDefault();
    document.getElementById("upload-file-zone").setAttribute("style","background-color: rgba(224,224,224,1)")
}

	 $('#upload-file-assay').fileupload({
             url:"upload-file-json.asp?<% = PID %>&formId=<%=formId%>&fieldId=<%=fieldId%>&random=<%=rnd%>&connectionId=<%=session("servicesConnectionId")%>",
             done:function(e,data){
                var  D= JSON.parse(data.result)
                var newId = window.parent.saveNew(D);
				document.getElementById("theFileId").value = newId
				window.frameElement.onchange();
				window.frameElement.src="upload_file_frame.asp?fileId="+newId;
             },
             dropZone: $('#upload-file-zone'),
			})
</script>
</html>
