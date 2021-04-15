<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'upload an attachment to an experiment%>
<%Server.ScriptTimeout=108000%>
<%
Response.CacheControl = "private"
Response.AddHeader "Pragma", "token"
Response.Expires = -1
'create an instance of the Browser 
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_decodeBase64.asp"-->
<!-- #include file="../_inclds/common/functions/sub_writeBytes.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
Call getconnectedadm
experimentType = request.querystring("experimentType")
experimentId = request.querystring("experimentId")
commentId = request.querystring("commentId")
commenterId = request.querystring("userId")
browserInfo = request.querystring("source")
ogFileName = request.querystring("description")

'generate paths make upload tree if it does not exist
path = uploadRoot & "\" & commenterId & "\commentAttachments\" & experimentType & "\" & experimentId & "\" & commentId
Call recursiveDirectoryCreate(uploadRootRoot, path)

Set Upload = Server.CreateObject("Persits.Upload")
Upload.IgnoreNoPost = True
Upload.OverwriteFiles = False
Upload.CodePage = 65001
' save the upload file
Upload.Save(path)

For Each File in Upload.Files
  filepath = File.Path
Next

If filepath <> "" Then
	'filename that was saved
	filename = Split(filepath,"\")(UBound(Split(filepath,"\")))
End If

' find the unique 16-long random string to replace the file name
exists = True
actualFileName = ""
Set fRec1 = server.CreateObject("ADODB.Recordset")
Do While exists
	actualFileName = getRandomString(32) & getFileExtension(filename)
	strQuery1 = "SELECT id FROM commentAttachments WHERE actualFileName="&SQLClean(actualFileName,"T","S")
	fRec1.open strQuery1,conn,adOpenForwardOnly,adLockReadOnly
	exists = not fRec1.eof
	fRec1.close
Loop
Set fRec1 = Nothing

'change filename to 16 random character name
set fso = CreateObject("Scripting.FileSystemObject") 
set file = fso.GetFile(path & "\" & filename) 
file.name = actualFileName 
set file = nothing 
set fso = nothing 

if ogFileName <> "" then
	fileName = ogFileName
end if

strQuery = "INSERT into commentAttachments(companyId,commenterId,experimentId,experimentType,filename,actualFilename,dateUploaded,dateUploadedServer,commentId) output inserted.id as newId values(" &_
	  SQLClean(session("companyId"),"N","S") & "," &_
	  SQLClean(commenterId,"N","S") & "," &_
	  SQLClean(experimentId,"N","S") & "," &_
	  SQLClean(experimentType,"N","S") & "," &_
	  SQLClean(fileName,"T","S") & "," &_
	  SQLClean(actualFileName,"T","S") & "," &_
	  "GETUTCDATE()," &_
	  "GETDATE()," &_
	  SQLClean(commentId,"N","S") & ")"

Set uploadResult = connAdm.execute(strQuery)
attachmentId = CStr(uploadResult("newId"))

' the response for ajax
uploadStr = "{" & """" & "result" & """" & ":" & """" & "succeed" & """"  
uploadStr = uploadStr & "," & """" & "commentId" & """" & ":" & commentId 
uploadStr = uploadStr & "," & """" & "userId" & """" & ":" & commenterId 
uploadStr = uploadStr & "," & """" & "filename" & """" & ":" & """" & fileName & """"
uploadStr = uploadStr & "," & """" & "attachmentId" & """" & ":"  & attachmentId & "}"

If InStr(1, browserInfo, "IE") <> 1 And InStr(1, browserInfo, "MSIE") <> 1 Then 'IE11 has "IE"; IE8/9/10 has "MSIE"
	response.contentType = "application/json charset=utf-8"
	response.write(uploadStr)
End If

Call disconnectadm
%>
