<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage = true%>
<%
Server.ScriptTimeout=108000
Response.CodePage = 65001
Response.CharSet = "UTF-8"
%>
<!-- #include file="_inclds/globals.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_recursiveDirectoryCreate.asp"-->
<!-- #include file="../_inclds/file_system/functions/fnc_getFileExtension.asp"-->
<!-- #include file="../_inclds/misc/functions/fnc_getRandomString.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))

Set Upload = Server.CreateObject("Persits.Upload")


path = uploadRoot&"\sciQuestImportFiles"
a = recursiveDirectoryCreate(uploadRootRoot,path)

Upload.Save(path)

For Each File in Upload.Files
	filepath = File.Path
Next

If filepath <> "" then
	'filename that was saved
	filename = Split(filepath,"\")(UBound(Split(filepath,"\")))
End If

fileExtension = Replace(getFileExtension(filename),".","")
If fileExtension = "txt" then
	actualFileName = getRandomString(16) & "." & fileExtension
	set fso = CreateObject("Scripting.FileSystemObject") 
	set file = fso.GetFile(filepath) 
	file.name = actualFileName 
	set file = nothing 
	set fso = Nothing

	pythonInputString = "{""fileName"":"""&actualFileName&""",""targetLocation"":"""&request.querystring("targetLocation")&""",""connectionId"":"""&session("servicesConnectionId")&"""}"

	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.open "POST",wsBase&"/sciQuestImport/",True
	http.setRequestHeader "Content-Type","text/plain;charset=UTF-8"
	http.setRequestHeader "Content-Length",Len(pythonInputString)
	http.SetTimeouts 360000,360000,360000,360000

	' ignore ssl cert errors
	http.setOption 2, 13056
	
	http.send pythonInputString
	http.waitForResponse(60)
	r = http.responseText
	response.write r
Else
	response.write "Your file is not a .txt file. It is a ." & fileExtension & " file and can't be imported."
End If

%>