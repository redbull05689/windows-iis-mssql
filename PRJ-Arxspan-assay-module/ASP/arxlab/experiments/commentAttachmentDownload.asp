<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_HTMLDecode.asp"-->
<%
server.scripttimeout = 60000
response.charset = "UTF-8"
response.codePage = 65001

commenterId = request.querystring("userId")
commentId = request.querystring("commentId")
attachmentId = request.querystring("attachmentId")
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")

filename = ""
actualFilename = ""
path = uploadRoot & "\" & commenterId & "\commentAttachments\" & experimentType & "\" & experimentId & "\" & commentId & "\"

Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT actualFilename, filename FROM commentAttachments WHERE id="&SQLClean(attachmentId,"N","S")
rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
If Not rec.eof Then
    actualFilename = rec("actualFilename")
    filename = rec("filename")
End if
rec.close
Set rec = Nothing

if actualFilename <> "" then
    'Set the content type to the specific type that you are sending.
    Response.ContentType = "application/octet-stream"     
    Response.AddHeader "Content-Disposition", "attachment; filename=""" & HTMLDecodeUnicodeRegex(filename) & """"

    set objStream = Server.CreateObject("ADODB.Stream")
    objStream.open
	const adTypeBinary = 1
    objStream.type = adTypeBinary
    objStream.LoadFromFile(path & actualFilename)
    response.binarywrite objStream.Read
    objStream.close
    Set objStream = nothing
End If
%>