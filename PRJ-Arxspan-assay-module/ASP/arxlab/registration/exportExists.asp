<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId="reg"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
fid = request.querystring("fid")

set fs=Server.CreateObject("Scripting.FileSystemObject")

doneFile = regInboxPath&fid&".done"
if fs.FileExists(doneFile) Then
	response.write("no")
Else
	response.write("yes")
End If
%>