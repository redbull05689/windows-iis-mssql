<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))

experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
justfilename = request.querystring("justfilename")

  'Make the image with JChem

Call getconnected
prefix = GetPrefix(experimentType)
tableName = GetFullName(prefix, "attachments", true)
presaveTableName = GetFullName(prefix, "attachments_preSave", true)
attachmentsTable = "(SELECT userId, actualFilename, experimentId, RevisionNumber FROM " & tableName & " UNION ALL SELECT userId, actualFilename, experimentId, RevisionNumber FROM " & presaveTableName & ") as T"
experimentTypeName = GetAbbreviation(experimentType)
Set attachmentRec2 = server.CreateObject("ADODB.recordset")
strQuery2 = "SELECT userId, actualFilename, RevisionNumber FROM "&attachmentsTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND actualFilename like "&SQLClean(justfilename,"L","S")
attachmentRec2.open strQuery2,conn,0,-1

fileExt = UCase(Replace(getFileExtension(attachmentRec2("actualFileName")),".",""))

molData = Base64Encode(ReadBinaryFile(uploadRootRoot&"\"&getCompanyIdByUser(attachmentRec2("userId"))&"\"&attachmentRec2("userId")&"\"&experimentId&"\"&attachmentRec2("RevisionNumber")&"\"&experimentTypeName&"\" & attachmentRec2("actualFileName")))

cdxmlPos = InStr(molData, "&lt;CDXML")
If cdxmlPos = 0 Then
  cdxmlPos = InStr(molData, "<CDXML")
End If

molDataFormat = "mol"
If cdxmlPos > 0 Then
  molDataFormat = "cdxml"
  molData = Mid(molData, cdxmlPos)
  molData = JSON.stringify(molData)
  molData = mid(molData, 2, Len(molData)-2)
End If

molData = HTMLDecode(molData)

data = "{""parameters"":""png:w1200,h400,nosource,maxscale28"",""inputFormat"":""base64:"& fileExt &""",""structure"":""" & molData & """}"

Set http = CreateObject("MSXML2.ServerXMLHTTP")
http.setOption 2, 13056
http.open "POST",chemAxonMolExportUrl,True
http.setRequestHeader "Content-Type","application/json"
http.setRequestHeader "Content-Length",Len(data)
http.SetTimeouts 120000,120000,120000,120000
http.send data
http.waitForResponse(60)

Set respJson = JSON.parse(http.responseText)
imageBase64 = respJson.Get("binaryStructure")

outputFileName = uploadRootRoot&"\"&getCompanyIdByUser(attachmentRec2("userId"))&"\"&attachmentRec2("userId")&"\"&experimentId&"\"&attachmentRec2("RevisionNumber")&"\"&experimentTypeName&"\"&Replace(attachmentRec2("actualFileName"),getFileExtension(attachmentRec2("actualFileName")),"_image.png")

If canViewExperiment(experimentType,experimentId,session("userId")) then
  response.write ("data:image/png;base64," + imageBase64)
End if

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

Function Base64Encode(bText)
    Dim oXML, oNode

    Set oXML = CreateObject("Msxml2.DOMDocument.3.0")
    Set oNode = oXML.CreateElement("base64")
    oNode.dataType = "bin.base64"
    oNode.nodeTypedValue =bText
    Base64Encode = oNode.text
    Set oNode = Nothing
    Set oXML = Nothing
End Function

%>