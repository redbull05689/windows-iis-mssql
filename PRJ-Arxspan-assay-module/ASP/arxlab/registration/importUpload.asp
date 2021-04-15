<!-- #include virtual="/_inclds/sessionInit.asp" -->
<script language="JScript" src="/arxlab/js/csvParse.asp" runat="server"></script>
<%
sectionId = "reg"
response.buffer = false
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
groupId = request.querystring("groupId")
If isInteger(request.querystring("groupId")) And groupId <> "0" Then
	isGroup = True
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT 1 FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
	If session("regRestrictedGroups") <> "" Then
		strQuery = strQuery & " AND id NOT IN ("&session("regRestrictedGroups")&")"
	End if
	rec.open strQuery,jchemRegConn,3,3
	If rec.eof Then
		title = "Error"
		message = "Group does not exist or you are not authorized to access it."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
	End if
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg
Else
	isGroup = False
End if
%>
<%
sectionId = "reg"
subSectionId = "import"
subSubSectionId = "upload"

if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If
%>
<%
server.scripttimeout = 10000
%>
<%
	Set Upload = Server.CreateObject("Persits.Upload")
	Upload.ProgressID = Request.QueryString("PID")
    a = recursiveDirectoryCreate(uploadRootRoot,session("companyId"))
	a = recursiveDirectoryCreate(uploadRoot,"RegBulkUploads")
    
	Upload.overwriteFiles = True
	Upload.Save(uploadRoot)
	For Each File in Upload.Files
		filepath = File.Path
	Next

	filename = Split(filepath,"\")(UBound(Split(filepath,"\")))
	fileExtension = Split(filename,".")(UBound(Split(filename,".")))
	filename = Replace(Replace(filename," ","_"),"-","")
	regFolderRoot = uploadRoot&"\RegBulkUploads"
    regFolderName = regFolderRoot&"\"&request.querystring("fid")
    a = recursiveDirectoryCreate(regFolderRoot,request.querystring("fid"))
	
	filePath2 = regFolderName&"\"&Replace(Replace(filename," ","_"),"-","")
	On Error Resume next
	Set fso = CreateObject("Scripting.FileSystemObject")
	newFilePath = regFolderName&"\"&Replace(Replace(filename," ","_"),"-","")
	If fso.FileExists(newFilePath) And newFilePath<>filepath Then
		fso.DeleteFile newFilePath,True
	End if
	fso.MoveFile filepath, filePath2
	filepath = filePath2
	Set fso = Nothing
	On Error goto 0

	If LCase(fileExtension) <> "csv" And LCase(fileExtension) <> "xls" And LCase(fileExtension) <> "xlsx" And LCase(fileExtension) <> "sdf" Then
		response.redirect(mainAppPath&"/static/errorMessage.asp?title=File Upload Error&message=File format is not recognized.  Please use CSV, TAB, or SDF")
	Else
		' If this is a bulk upload, we only allow sdf file upload for Small Molecule
		source = Request.QueryString("source")
		If Not isGroup And source = "compounds" And LCase(fileExtension) <> "sdf" Then
			' This is an upload for Small Molecule	
			response.redirect(mainAppPath&"/static/errorMessage.asp?title=File Upload Error&message=Uploaded file must contain a field titled 'Structure' and must have the extension '.sdf'.")
		End If
	End if

	session("regUploadfilename") = filename
	session("regUploadFullPath") = Replace(filepath,"\","\\")
    session.Save()

	originalFilename = Split(filepath,"\")(UBound(Split(filepath,"\")))
	response.redirect("importMapFields.asp?fid="&request.querystring("fid")&"&makeBatches="&upload.form("makeBatches")&"&needsPurification="&upload.form("needsPurification")&"&replaceKey="&upload.form("replaceKey")&"&originalFilename="&originalFilename&"&source="&request.querystring("source")&"&groupId="&groupId&"&sdId="&request.querystring("sdId"))
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->

<div class="registrationPage">
</div>

<!-- #include file="../_inclds/footer-tool.asp"-->