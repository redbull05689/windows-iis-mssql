<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_convertToCDXML.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
If Not(session("hasAccordInt") And session("regRoleNumber") <= 15) Then
	response.redirect("logout.asp")
End If
%>
<%
Function ReadBinaryFile(FileName)
  Const adTypeBinary = 1
  
  'Create Stream object
  Dim BinaryStream
  Set BinaryStream = CreateObject("ADODB.Stream")
  
  'Specify stream type - we want To get binary data.
  BinaryStream.Type = adTypeBinary
  
  'Open the stream
  BinaryStream.Open
  
  'Load the file data from disk To stream object
  BinaryStream.LoadFromFile FileName
  
  'Open the stream And get binary data from the object
  ReadBinaryFile = BinaryStream.Read
End Function

Function SaveBinaryData(FileName, ByteArray)
  Const adTypeBinary = 1
  Const adSaveCreateOverWrite = 2
  
  'Create Stream object
  Dim BinaryStream
  Set BinaryStream = CreateObject("ADODB.Stream")
  
  'Specify stream type - we want To save binary data.
  BinaryStream.Type = adTypeBinary
  
  'Open the stream And write binary data To the object
  BinaryStream.Open
  BinaryStream.Write ByteArray
  
  'Save binary data To disk
  BinaryStream.SaveToFile FileName, adSaveCreateOverWrite
End Function

Function sortIntegerArray(arrayOfTerms)
	for a = UBound(ArrayOfTerms) - 1 To 0 Step -1
		for j= 0 to a
			if Int(ArrayOfTerms(j))>Int(ArrayOfTerms(j+1)) then
				temp=ArrayOfTerms(j+1)
				ArrayOfTerms(j+1)=ArrayOfTerms(j)
				ArrayOfTerms(j)=temp
			end if
		next
	next 
	sortIntegerArray = ArrayOfTerms
End function

path = uploadRoot & "\" & session("userId") & "\accint"
a = recursiveDirectoryCreate(uploadRootRoot,path)

If request.querystring("m")="" Or request.querystring("m")="0" then
	Set Upload = Server.CreateObject("Persits.Upload")
	Upload.Save(path)

	For Each File in Upload.Files
		filepath = File.Path
	Next
End If

fid = getRandomString(16)
actualFilename = fid&".cdxml"

If request.querystring("m") = "1" Then
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	filepath = path&"\"&actualFilename
	Set tfile=fs.CreateTextFile(filepath)
	tfile.WriteLine(request.Form("cdxmlData"))
	tfile.close
	set tfile=nothing
	set fs=nothing	
End if

If request.querystring("m")="" Or request.querystring("m")="0" then
	set fso = CreateObject("Scripting.FileSystemObject") 
	set file = fso.GetFile(filepath) 
	file.name = actualFileName
	set file = nothing 
	set fso = nothing 
End if

Call getconnectedJchemReg
strQuery = "INSERT INTO accUploads(fid,userId,companyId,dateUpdloaded) output inserted.id as newId values(" &_
			SQLClean(fid,"T","S") & "," &_
			SQLClean(session("userId"),"N","S") & "," &_
			SQLClean(session("companyId"),"N","S") & ",GETDATE())"
Set rs = jchemRegConn.execute(strQuery)
uploadId = CStr(rs("newId"))
Call disconnectJchemReg

If request.querystring("m")="" Or request.querystring("m")="0" then
	xmlStr = convertToCDXMLFromFilePath(path&"\"&actualFilename)
elseif request.querystring("m") = "1" Then
	xmlStr = request.Form("cdxmlData")
	cdxmlPos = InStr(xmlStr, "<CDXML")
	If cdxmlPos = 0 Then
		xmlStr = convertToCDXML(xmlStr, None)
	end if
else
	xmlStr = None
end if

' Remove the XML and doctype declarations
cdxmlPos = InStr(xmlStr, "<CDXML")
If cdxmlPos > 0 Then
	xmlStr = Right(xmlStr, Len(xmlStr) - cdxmlPos + 1)
End If

Set xml = Server.CreateObject("Microsoft.XMLDOM")
xml.LoadXML(xmlStr)

Call getconnectedJchemReg

Dim buf
' loop each fragment and add it as its own CDXML file to accMols
For Each oNode In xml.getElementsByTagName("fragment")
	Set buf = CreateObject("System.IO.StringWriter")
	' get the CDXML tag and its attributes
	For Each cdxmlNode In xml.getElementsByTagName("CDXML")
		buf.Write_12 "<CDXML"
		For Each cdxmlAttr In cdxmlNode.Attributes
			buf.Write_12 " "
			buf.Write_12 CStr(cdxmlAttr.Name)
			buf.Write_12 "="""
			buf.Write_12 CStr(cdxmlAttr.Value)
			buf.Write_12 """"
		Next
		buf.Write_12 ">"
	Next

	' make the colortable
	For Each colorTableNode In xml.getElementsByTagName("colortable")
		buf.Write_12 colorTableNode.xml
	Next

	' make the fonttable
	For Each fontTableNode In xml.getElementsByTagName("fonttable")
		buf.Write_12 fontTableNode.xml
	Next

	' add the page and end the page and cdxml
	buf.Write_12 "<page>"
	buf.Write_12 oNode.xml
	buf.Write_12 "</page></CDXML>"
	
	' convert to MOL
	'  escape the xml for JSON first
	strTheCDXML = buf.GetStringBuilder().ToString()
	strTheCDXML = replace(strTheCDXML, "\", "\\")
	strTheCDXML = replace(strTheCDXML, """", "\""")
	strTheCDXML = replace(strTheCDXML, vbcr, "\r")
	strTheCDXML = replace(strTheCDXML, vblf, "\n")
	strTheCDXML = replace(strTheCDXML, vbtab, "\t")

	'  get mol from jchem
	strMol = CX_convertStructure(strTheCDXML, "cdxml", "mol:V3")

	' save it to the database
	strQuery = "INSERT INTO accMols(structure,uploadId,uploaded) values ("&_
				SQLClean(strMol,"T","S") & "," &_
				SQLClean(uploadId,"N","S") & ",0)"
	jChemRegConn.execute(strQuery)

	Set buf = nothing
Next
Call disconnectJchemReg
response.redirect("show-file.asp?fid="&fid)
%>