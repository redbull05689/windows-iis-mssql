<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<%response.charset = "UTF-8"%>
<%response.codePage = 65001%>
<%Server.scripttimeout=180000%>
<%response.buffer = false%>
<%isApiPage=True%>
<!-- #include file="../_inclds/globals.asp"-->
<%
errMsg = ""
session("companyId") = ""

Set jsonReq = JSON.Parse(request.form)
If (Not IsObject(jsonReq)) Or (Not jsonReq.Exists("updatedSinceEpoch")) Then
	errMsg = errMsg & "updatedSinceEpoch is a required parameter"
	response.write(errMsg)
	response.end()
End If

data = request.form
%>
<!-- #include virtual="/arxlab/_inclds/globals_apis.asp" -->
<%
If session("companyId") <> "" Then
    Set tables = JSON.Parse("[{""table"":""experimentView"",""type"":1},{""table"":""bioExperimentsView"",""type"":2},{""table"":""freeExperimentsView"",""type"":3},{""table"":""analExperimentsView"",""type"":4},{""table"":""custExperimentsView"",""type"":5}]")

	recId = 0
	response.write("[")
	Do While recId < tables.length
		Set table = tables.Get(recId)
        Set xmlRec = server.CreateObject("ADODB.Recordset")
		strQuery = "SELECT * from " & table.Get("table") & " WHERE visible=1 and companyId=" & session("companyId") &_
		" and dateUpdated >= DATEADD(SECOND, " & SQLClean(jsonReq.Get("updatedSinceEpoch"),"N","N") & ", '1970-01-01')"
        xmlRec.open strQuery,conn,3,3
		
		firstRec = True
        Do While Not xmlRec.eof
			If firstRec Then
				firstRec = False
			Else
				response.write(",")
			End If
			
            Set recJson = JSON.Parse("{}")
            recJson.Set "experimentType", table.Get("type")
            recJson.Set "experimentId", CLng(xmlRec("id"))
            response.write(JSON.Stringify(recJson))
			Set recJson = Nothing
			xmlRec.movenext
        Loop
        xmlRec.close
        Set xmlRec = Nothing
		recId = recId + 1
    Loop
	
	response.write("]")
	response.end()
End If
%>