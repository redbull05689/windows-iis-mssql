<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentId = request.querystring("id")
revisionNumber = request.querystring("revisionNumber")
attachment = request.querystring("attachment")
stepNumber = ""
experimentType = 1
If canViewExperiment(1,experimentId,session("userId")) Or session("userId") = "2" then
	Call getconnected
	If revisionNumber = "" Then
		strQuery = "SELECT name,cdx FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT name,cdx FROM experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") 
	End if
	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		cdxData = Replace(rec("cdx"),"\""","""")
		If revisionNumber = "" And ((session("hasInventoryIntegration") And session("hasCompoundTracking")) Or session("hasBarcodeChooser")) And ownsExperiment("1",experimentId,session("userId")) Then
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT experimentJSON FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
			rec2.open strQuery,conn,3,3
			If Not rec2.eof then
				Set experimentJSON = JSON.parse(rec2("experimentJSON"))
				If experimentJSON.exists("cdxml") then
					cdxData = experimentJSON.Get("cdxml")
				End if
			End If
			rec2.close
			Set rec2 = nothing
		End if
	End If
	If stepNumber <> "" Then
		If revisionNumber = "" Then
			strQuery = "SELECT cdx FROM experiment_steps WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND stepNumber="&SQLClean(stepNumber,"N","S")
		Else
			strQuery = "SELECT cdx FROM experiment_stepsHistory WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND stepNumber="&SQLClean(stepNumber,"N","S")&" AND revisionNumber="&SQLClean(revisionNumber,"N","S")
		End if
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		rec2.open strQuery,conn,3,3
		If Not rec2.eof Then
			cdxData = Replace(rec2("cdx"),"\""","""")
		End If
		rec2.close
		Set rec2 = nothing
	End If
	response.contenttype="application/octet-stream"
	response.addheader "ContentType","application/octet-stream"
	If attachment = "" then
		response.addheader "Content-Disposition", "inline; " & "filename="&Replace(cleanFileName(rec("name")),",","")&"-reaction.cdxml"
	Else
		response.addheader "Content-Disposition", "attachment; " & "filename="&Replace(Replace(cleanFileName(rec("name"))," ","_"),",","")&"-reaction.cdxml"
	End if
	'Response.AddHeader "Content-Length", Len(cdxData)
	'response.write(cdxData)

	'convert structure data to mol data using jchem
    Set d = JSON.parse("{}")
    d.Set "structure", cdxData
    d.Set "parameters", "mol"
    
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
    rxnData = r.Get("structure")


	
	response.write(Server.urlEncode(rxnData))
	doc.Close()
	Set doc = Nothing
	chemDraw.quit()
	Set chemDraw = Nothing
End if
%>