<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="./returnImageFile.asp"-->
<%

	returnedFile = False
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	filename = "logo.gif"
	logoFilePath = uploadRoot&"\logo.gif"
	If fs.FileExists(logoFilePath)=true Then
		response.contenttype="image/gif"
		response.addheader "ContentType","image/gif"
		response.addheader "Content-Disposition", "inline; " & "filename=logo.gif"
		returnedFile = returnImageFile(uploadRoot&"\", filename, server.mappath(mainAppPath)&"/images/", "return-error")
	End If
			
%>