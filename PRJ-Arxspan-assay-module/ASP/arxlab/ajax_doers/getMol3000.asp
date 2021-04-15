<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<%
	'convert structure data to mol3000 data using jchem
	
    Set d = JSON.parse("{}")
    d.Set "structure", CStr(request.querystring("molData"))
    d.Set "parameters", "mol:V3"
    
    data = JSON.stringify(d)
    Set http = CreateObject("MSXML2.ServerXMLHTTP")
    http.setOption 2, 13056
    http.open "POST",chemAxonMolExportUrl,True
    http.setRequestHeader "Content-Type","application/json" 
    http.setRequestHeader "Content-Length",Len(data)
    http.SetTimeouts 120000,120000,120000,120000
    http.send data
    http.waitForResponse(60)
    Set r = JSON.parse(http.responseText)
    molData = r.Get("structure")
	response.write(molData)
%>