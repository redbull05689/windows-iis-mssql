<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
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
<body>
<%
formId = request.querystring("formId")
fieldId = request.querystring("fieldId")
fileId = request.querystring("fileId")
collection = request.querystring("collection")
connectionId = request.querystring("connectionId")
%>

<%If fileId <> "" then%>
	<%
	s = connectionId&","&fileId&","&collection
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.setOption 2, 13056
	http.open "POST",wsBase&"/getFileInfo/",True
	http.setRequestHeader "Content-Type","text/plain"
	http.setRequestHeader "Content-Length",Len(s)
	http.send s
	http.waitForResponse(60)
	r = http.responseText
	If r <> "" Then
		a = Split(r,",")
		filename = a(0)
		fileExtension = a(1)
		displayFilename = a(2)
		uploadPath = a(3)
	%>
		<a href="<%If fileId="" then%>javascript:void(0);<%else%>getSourceFile.asp?fileId=<%=fileId%>&collection=<%=collection%>&connectionId=<%=session("servicesConnectionId")%><%End if%>" id="<%=fileId%>_download_button" class="littleButton" style="float:none;width:80px;display:inline;margin-left:10px;<%If fileId="" then%>display:none;<%End if%>">Download <%=displayFilename%></a>

		<div id="<%=fileId%>_img_holder" style="margin-left:15px;<%If fileId="" Or not canDisplayInBrowser(filename) then%>display:none;<%End if%>">
		<a href="javascript:void(0);" onclick="document.getElementById('<%=fileId%>_img').style.display='block';document.getElementById('<%=fileId%>_img_show').style.display='none';document.getElementById('<%=fileId%>_img_hide').style.display='inline';resizeIframe('<%=fileId%>_img','<%=fieldId%>_frame');" <%If fileId="" then%>style="display:none;"<%End if%> id="<%=fileId%>_img_show">Show Image</a>
		<a href="javascript:void(0);" onclick="document.getElementById('<%=fileId%>_img').style.display='none';document.getElementById('<%=fileId%>_img_hide').style.display='none';document.getElementById('<%=fileId%>_img_show').style.display='inline';resizeIframe('<%=fileId%>_img','<%=fieldId%>_frame')" id="<%=fileId%>_img_hide" <%If fileId<>"" then%>style="display:none;"<%End if%>>Hide Image</a>
		<img src="<%If fileId="" then%>javascript:false<%else%>getImage.asp?fileId=<%=fileId%>&collection=<%=collection%>&connectionId=<%=session("servicesConnectionId")%><%End if%>" style="<%If inframe then%>width:200px;<%else%>width:800px;<%End if%>display:none;" id="<%=fileId%>_img"/>
		</div>
	<%End if%>
<%End if%>

<%If request.querystring("readOnly") <> "true" then%>
<form action="upload-file.asp?<% = PID %>&formId=<%=formId%>&fieldId=<%=fieldId%>&random=<%=rnd%>&connectionId=<%=session("servicesConnectionId")%>" method="post" ENCTYPE="multipart/form-data" OnSubmit="return showProgress();">
	<input type="file" name="file" id="file">
	<input type="submit" <%If fileId="" then%>value="Upload"<%else%>Value="Reupload"<%End if%>>
</form>
<%End if%>
</body>
</html>