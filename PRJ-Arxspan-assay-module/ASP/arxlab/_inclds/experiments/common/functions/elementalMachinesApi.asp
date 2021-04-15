<%
Function getAccessToken()
	getAccessToken = ""

	If session("elementalMachinesUserName") = "" Or session("elementalMachinesPassword") = "" Or session("elementalMachinesClientId") = "" Or session("elementalMachinesClientSecret") = "" Then 
		Set emRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "select * from elementalMachinesCompanyConfig where companyId=" & SQLClean(session("companyId"), "N", "S")
		emRec.open strQuery,conn,0,-1

		If Not emRec.eof Then
			session("elementalMachinesClientId") = emRec("client_id")
			session("elementalMachinesClientSecret") = emRec("client_secret")
		End If
	End If

	If session("elementalMachinesUserName") <> "" And session("elementalMachinesPassword") <> "" And session("elementalMachinesClientId") <> "" And session("elementalMachinesClientSecret") <> "" Then 
		tokenData = "{""username"":"""&session("elementalMachinesUserName")&""",""password"":"""&session("elementalMachinesPassword")&""",""client_id"":"""&session("elementalMachinesClientId")&""",""client_secret"":"""&session("elementalMachinesClientSecret")&""",""grant_type"":""password""}"
		Set http = CreateObject("MSXML2.ServerXMLHTTP")
		http.open "POST","https://api.elementalmachines.io/oauth/token/",True
		http.setRequestHeader "Content-Type","application/json"
		http.setRequestHeader "Content-Length",Len(data)
		http.send tokenData
		http.waitForResponse(60)

		Set r = JSON.parse(http.responseText)
		Set http = Nothing
		
		getAccessToken = r.Get("access_token")
	End If
End Function

Function getListOfMachines()
	getListOfMachines = "[]"
	
	accessToken = getAccessToken()
	If accessToken <> "" Then
		Set http = CreateObject("MSXML2.ServerXMLHTTP")
		http.open "GET","https://api.elementalmachines.io/api/machines.json?access_token="&accessToken,True
		http.send
		http.waitForResponse(60)
		getListOfMachines = http.responseText
		Set http = Nothing
	End If
End Function

Function getListOfSamplesFromMachine(machineUuid, startEpoch, endEpoch)
	getListOfSamplesFromMachine = "[]"

	accessToken = getAccessToken()
	If accessToken <> "" Then
		httpUrl = "https://api.elementalmachines.io/api/machines/"&machineUuid&"/samples.json?access_token="&accessToken

		If startEpoch <> "" and endEpoch <> "" Then
			httpUrl = httpUrl & "&from=" & startEpoch & "&to=" & endEpoch
		End if

		Set http = CreateObject("MSXML2.ServerXMLHTTP")
		http.open "GET", httpUrl,True
		http.send
		http.waitForResponse(60)
		getListOfSamplesFromMachine = http.responseText
		Set http = Nothing
	End If
End Function
%>