<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
craisCheckerUrl = getCompanySpecificSingleAppConfigSetting("craisCheckerUrlEndpoint", session("companyId"))
craisCheckerUser = getCompanySpecificSingleAppConfigSetting("craisCheckerUser", session("companyId"))
craisCheckLevel = getCompanySpecificSingleAppConfigSetting("craisCheckLevel", session("companyId"))
craisCheckApplication = getCompanySpecificSingleAppConfigSetting("craisCheckApplication", session("companyId"))
Server.scriptTimeout = 6000
Response.CodePage = 65001
Response.Charset = "UTF-8"
response.AddHeader "Content-Type", "text/html;charset=UTF-8"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_duplicateAndChangeStatus.asp"-->
<%
Function getCraisResult(structure)
	' 5791 - This is more or less a null or empty string check. If they are null or empty, then get an empty structure.
	' CRAIS seems to be ok with being passed an empty structure.
	structure = getEmptyStructureIfNeeded(structure)
	soapEnv = "<Envelope xmlns=""http://schemas.xmlsoap.org/soap/envelope/"">" &_
			  " <Body>" &_
			  "  <CheckExecute4 xmlns=""http://tempuri.org/"">" &_
			  "   <structure>"&server.HTMLEncode(structure)&"</structure>" &_
			  "   <checkLevel>"&craisCheckLevel&"</checkLevel>" &_
			  "   <userAccount>"&craisCheckerUser&"</userAccount>" &_
			  "   <appName>"&craisCheckApplication&"</appName>" &_
			  "   <keyField></keyField>" &_
			  "   <hitType>1</hitType>" &_
			  "   <checkCharge>false</checkCharge>" &_
			  "   <checkValence>false</checkValence>" &_
			  "   <checkAtom>false</checkAtom>" &_
			  "   <lastUpdateFrom></lastUpdateFrom>" &_
			  "   <lastUpdateTo></lastUpdateTo>" &_
			  "  </CheckExecute4>" &_
			  " </Body>" &_
			  "</Envelope>"
	set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
	xmlhttp.Open "POST",craisCheckerUrl,True
	xmlhttp.setRequestHeader "Content-Type", "text/xml"
	xmlhttp.send soapEnv
	xmlhttp.waitForResponse(60)
	getCraisResult = xmlhttp.responsexml.xml
End Function

Function getCraisClass(bXML)
	className = ""
	Dim xml
	Set xml = server.CreateObject("Microsoft.XMLDOM")
	xml.loadXML(bXML)
	For Each oNode In xml.SelectNodes("//CategoryGroupName")
		If oNode.text = "CLASS-A" Then
			foundClassA = true
		End If
		If oNode.text = "CLASS-B" Then
			foundClassB = true
		End If
		className = oNode.text
	Next
	'order is very important here
	If foundClassB Then
		className = "CLASS-B"
	End if
	If foundClassA Then
		className = "CLASS-A"
	End if
	getCraisClass = className
End function

Function Konvert(strIn)
	newText = ""
	Dim i
	For i = 1 To Len(strIn)
		ch = Mid(strIn,i,1)
		co = ascw(ch)
		If co<0 Then
			co = co + 65536
		End if
		If co<128 Then
			newText = newText & ch
		Else
			newText = newText & "&#"&co&";"
		End if
	Next
	Konvert = newText
End Function

Function getCraisText(bXML)
	Dim xml
	theText = ""
	Set xml = server.CreateObject("Microsoft.XMLDOM")
	xml.loadXML(bXML)
	categoryCodes = ""
	For Each oNode In xml.SelectNodes("//HitResult")
		categoryCode = "-1"
		For Each oNode2 In oNode.SelectNodes("CategoryCode")
			categoryCode = oNode2.text
		Next
		If InStr(categoryCodes,","&categoryCode)<=0 Then
			For Each oNode2 In oNode.SelectNodes("StructureName")
				If oNode2.text <> "" then
					theText = theText & Konvert(oNode2.text) & "<br/>"
				End if
			Next
			For Each oNode2 In oNode.SelectNodes("CategoryName")
				If oNode2.text <> "" then
					theText = theText & Konvert(oNode2.text) & "<br/>"
				End if
			Next
			theText = theText &"Category code: "&categoryCode&"<br/>"
			theText = theText & "<br/>"
		End if
		If categoryCode <> "-1" then
			categoryCodes = categoryCodes & "," & categoryCode
		End if
	Next

	getCraisText = theText
End function

experimentId = request.querystring("experimentId")
If ownsExperiment("1",experimentId,session("userId")) And session("hasCrais") And craisCheckerUrl <> "" And craisCheckerUser <> "" Then
	Call getconnected
	Call getconnectedadm

	failedCheck = false
	warning = false

	Set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT id, molData3000 FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		xml = getCraisResult(rec("molData3000"))
		craisClass = getCraisClass(xml)
		If craisClass = "CLASS-A" or xml = "" Then
			failedCheck = true
		End If
		If craisClass = "CLASS-B" Then
			warning = true
		End if
		craisText = getCraisText(xml)
		strQuery2 = "UPDATE reactants SET craisClass="&SQLClean(craisClass,"T","S")&",craisText="&SQLClean(craisText,"T","S")&" WHERE id="&SQLClean(rec("id"),"N","S")
		connAdm.execute(strQuery2)
		rec.movenext
	Loop
	rec.close
	Set rec = nothing

	Set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT id, molData3000 FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		xml = getCraisResult(rec("molData3000"))
		craisClass = getCraisClass(xml)
		If craisClass = "CLASS-A" or xml = "" Then
			failedCheck = true
		End If
		If craisClass = "CLASS-B" Then
			warning = true
		End if
		craisText = getCraisText(xml)
		strQuery2 = "UPDATE reagents SET craisClass="&SQLClean(craisClass,"T","S")&",craisText="&SQLClean(craisText,"T","S")&" WHERE id="&SQLClean(rec("id"),"N","S")
		connAdm.execute(strQuery2)
		rec.movenext
	Loop
	rec.close
	Set rec = nothing

	Set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT id, molData3000 FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		xml = getCraisResult(rec("molData3000"))
		craisClass = getCraisClass(xml)
		If craisClass = "CLASS-A" or xml = "" Then
			failedCheck = true
		End If
		If craisClass = "CLASS-B" Then
			warning = true
		End if
		craisText = getCraisText(xml)
		strQuery2 = "UPDATE products SET craisClass="&SQLClean(craisClass,"T","S")&",craisText="&SQLClean(craisText,"T","S")&" WHERE id="&SQLClean(rec("id"),"N","S")
		connAdm.execute(strQuery2)
		rec.movenext
	Loop
	rec.close
	Set rec = nothing

	Set rec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT id, molData3000 FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		xml = getCraisResult(rec("molData3000"))
		craisClass = getCraisClass(xml)
		If craisClass = "CLASS-A" or xml = "" Then
			failedCheck = true
		End If
		If craisClass = "CLASS-B" Then
			warning = true
		End if
		craisText = getCraisText(xml)
		strQuery2 = "UPDATE solvents SET craisClass="&SQLClean(craisClass,"T","S")&",craisText="&SQLClean(craisText,"T","S")&" WHERE id="&SQLClean(rec("id"),"N","S")
		connAdm.execute(strQuery2)
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	
	oldRevisionNumber = duplicateAndChangeStatus("1",experimentId,"9",true)
	maxRevisionNumber = getExperimentRevisionNumber("1",experimentId)

	craisStatus = 1
	If warning Then
		craisStatus = 2
	End If
	If failedCheck Then
		craisStatus = 3
	End if
	strQuery2 = "UPDATE experiments SET craisStatus="&SQLClean(craisStatus,"N","S")&" WHERE id="&SQLClean(experimentId,"N","S")
	connAdm.execute(strQuery2)
	strQuery2 = "UPDATE experiments_history SET craisStatus="&SQLClean(craisStatus,"N","S")&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND revisionNumber="&SQLClean(maxRevisionNumber,"N","S")
	connAdm.execute(strQuery2)
	Call disconnect
	Call disconnectadm
	response.redirect(mainAppPath & "/" & session("expPage")&"?id="&experimentId)
End if
%>