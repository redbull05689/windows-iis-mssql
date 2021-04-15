<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
' Takes CDXML and applies a stylesheet to it
' You can pass the name of the stylesheet OR the stylesheet CDXML
' if isHalf = true,  template bond length will be divided by 2 () 

Function applyStylesHalf(originCDXML, templateName, templateCdxml, isHalf)
    On Error GoTo 0

    CDXConvertUrl = getCompanySpecificSingleAppConfigSetting("cdxmlServiceEndpointUrl", session("companyId"))

    'Take the CDX and get CDXML
    Set j = JSON.parse("{}")

    j.Set "cdxml", pEscape(originCDXML)
	J.Set "templateCdxml", pEscape(templateCdxml)
	J.Set "templateName", templateName
    j.Set "appName", "Configuration"
    j.Set "isHalf", isHalf
    
    jData = JSON.stringify(j)
    Set http2 = CreateObject("MSXML2.ServerXMLHTTP")
    http2.setOption 2, 13056
    http2.open "POST", CDXConvertUrl & "/Style", True
    http2.setRequestHeader "Content-Type","application/json; charset=US-ASCII" 
    http2.setRequestHeader "Accept","application/json"
    http2.setRequestHeader "Content-Length",Len(jData)
    http2.setRequestHeader "Authorization", session("jwtToken")
    http2.SetTimeouts 120000,120000,120000,120000
    http2.send jData
    http2.waitForResponse(60)
    set responseObject = JSON.parse(http2.responseText)
    xmlStr = responseObject.Get("data")
    
    applyStylesHalf = xmlStr
end function

Function applyStyles(originCDXML, templateName, templateCdxml)
    On Error GoTo 0

    CDXConvertUrl = getCompanySpecificSingleAppConfigSetting("cdxmlServiceEndpointUrl", session("companyId"))

    'Take the CDX and get CDXML
    Set j = JSON.parse("{}")

    j.Set "cdxml", pEscape(originCDXML)
	J.Set "templateCdxml", pEscape(templateCdxml)
	J.Set "templateName", templateName
    j.Set "appName", "Configuration"
    j.Set "isHalf", 0
    
    jData = JSON.stringify(j)
    Set http2 = CreateObject("MSXML2.ServerXMLHTTP")
    http2.setOption 2, 13056
    http2.open "POST", CDXConvertUrl & "/Style", True
    http2.setRequestHeader "Content-Type","application/json; charset=US-ASCII" 
    http2.setRequestHeader "Accept","application/json"
    http2.setRequestHeader "Content-Length",Len(jData)
    http2.setRequestHeader "Authorization", session("jwtToken")
    http2.SetTimeouts 120000,120000,120000,120000
    http2.send jData
    http2.waitForResponse(60)
    set responseObject = JSON.parse(http2.responseText)
    xmlStr = responseObject.Get("data")
    
    applyStyles = xmlStr
end function
%>