<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
    accordServicePath = getCompanySpecificSingleAppConfigSetting("accordServiceEndpointUrl", session("companyId"))

    function searchAccordStructures(structure)
        If Left(structure,2) = vbcrlf Then
            structure = "blankId" & structure
        End if

        soapEnv = 	"<?xml version=""1.0"" encoding=""utf-8""?>" &_
        "<structures><structure>"&server.htmlencode(structure)&"</structure></structures>"
        'response.write(soapEnv)

		Set xmlhttp = CreateObject("MSXML2.ServerXMLHTTP")
		xmlhttp.setOption 2, 13056
        xmlhttp.Open "POST",accordServicePath&"/searchmols/",True
        xmlhttp.setRequestHeader "Content-Type", "text/xml"
        'xmlhttp.SetTimeouts 15000,60000,60000,60000
        
        Dim aErr
        On Error Resume Next
        xmlhttp.send soapEnv
		xmlhttp.waitForResponse(60)
        aErr = Array(Err.Number, Err.Description)
        On Error GoTo 0
        
        If 0 <> aErr(0) Then
            response.write("Error contacting Accord: " & aErr(0) & " " & aErr(1))
        End If
        
        searchAccordStructures = HTMLDecode(xmlhttp.responsexml.xml)
    end function
%>