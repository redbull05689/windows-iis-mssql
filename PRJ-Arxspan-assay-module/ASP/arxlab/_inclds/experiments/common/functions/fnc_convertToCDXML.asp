<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<!-- #include virtual="/arxlab/_inclds/escape_and_filter/functions/fnc_decodeBase64Motobit.asp"-->
<!-- #include virtual="/arxlab/_inclds/experiments/common/functions/fnc_getFileFormat.asp"-->
<%
CDXConvertUrl = getCompanySpecificSingleAppConfigSetting("cdxmlServiceEndpointUrl", session("companyId"))

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

Function convertToCDXMLFromFilePath(filePath)
    base64MolData = Base64Encode(ReadBinaryFile(filePath))
    stringMolData = decodeBase64(base64MolData)
    bestGuessFileFormat = getFileFormat(stringMolData)

    ' check to see if this is already CDXML, if so just return it. Otherwise, convert it
    if bestGuessFileFormat = "cdxml" then
        convertToCDXMLFromFilePath = stringmolData
    else
        convertToCDXMLFromFilePath = convertToCDXML(base64MolData, bestGuessFileForamt) '"base64:cdx"
    end if
end function

' Takes anything JChem can read and converts it to CDXML
Function convertToCDXML(fileData, fileType)
    On Error GoTo 0
    ' Upload to jchem to get the CDX

    Set d = JSON.parse("{}")
    'response.write("<br />File Data: " & fileData)
    d.Set "structure", fileData
    d.Set "parameters", "base64:cdx"
    if (Not IsNull(fileType)) then
      d.Set "inputFormat", fileType
    end if
    
    data = JSON.stringify(d)
    'response.write("<br />Data: " & data)
    Set http = CreateObject("MSXML2.ServerXMLHTTP")
    http.setOption 2, 13056
    http.open "POST",chemAxonMolExportUrl,True
    http.setRequestHeader "Content-Type","application/json" 
    http.setRequestHeader "Content-Length",Len(data)
    http.SetTimeouts 120000,120000,120000,120000
    http.send data
    http.waitForResponse(60)
    Set r = JSON.parse(http.responseText)
    base64cdx = r.Get("structure")

    base64cdx = Replace(base64cdx,"\n",vblf)

    'response.write("<br />base64: " & base64cdx)

     'Take the CDX and get CDXML
    Set j = JSON.parse("{}")
    'response.write("<br />File Data: " & fileData)
    j.Set "base64Cdx", pEscape(base64cdx)
    j.Set "appName", "Configuration"
    j.Set "outType","cdxml"
    
    jData = JSON.stringify(j)
    Set http2 = CreateObject("MSXML2.ServerXMLHTTP")
    http2.setOption 2, 13056

    'switch to new endpoint for cdx conversion
    http2.open "POST", CDXConvertUrl & "/cdxmlconv2x", True
    http2.setRequestHeader "Content-Type","application/json; charset=US-ASCII" 
    http2.setRequestHeader "Accept","application/json"
    http2.setRequestHeader "Content-Length",Len(jData)
    http2.setRequestHeader "Authorization", session("jwtToken")
    http2.SetTimeouts 120000,120000,120000,120000
    http2.send jData
    http2.waitForResponse(60)
    set responseObject = JSON.parse(http2.responseText)
    xmlStr = responseObject.Get("data")
    
    convertToCDXML = xmlStr
    'response.write("<br />inputText: " & jData)
    'response.write(vbcrlf & vbcrlf & vbcrlf & "<br />responseText: " & http2.responseText)
end function

%>