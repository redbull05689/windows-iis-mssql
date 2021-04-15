<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
sectionId = "reg"
subSectionId = "search"
if Not (session("regRegistrar") Or session("regUser")) Then
	response.redirect("logout.asp")
End If
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<%
server.scripttimeout = 250000
response.buffer = false
%>



<%
If request.Form("overrideCdids") <> "" Then
	cdIdStr = request.Form("overrideCdids")
Else
	cdIdStr = "("
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open session("tableStrQuery"),jchemRegConn,3,3
	Do While Not rec.eof
		cdIdStr = cdIdStr & rec("cd_id")
		rec.movenext
		If Not rec.eof Then
			cdIdStr = cdIdStr & ","
		End if
	loop
	rec.close
	Set rec = Nothing
	cdIdStr = cdIdStr & ")"
	Call disconnectJchemReg
End if

filename = request.Form("exportFid")&".search"
queryMol = session("regSearchMolData")
If queryMol = "" Then
	queryMol = "*"
End if

regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
regNumberPrefix = getCompanySpecificSingleAppConfigSetting("regNumberPrefix", session("companyId"))
Set D = new LD
D.addPair "whichServer",whichServer
D.addPair "server",RegDatabaseName
D.addPair "dbServerIP", regDataBaseServerIP
D.addPair "regNumberPrefix",regNumberPrefix
D.addPair "userId",session("userId")
D.addPair "userEmail",session("email")
D.addPair "cdIdStr",cdIdStr
D.addPair "regBatchNumberLength",regBatchNumberLength
D.addPair "regBatchNumberDelimiter",regBatchNumberDelimiter
D.addPair "regNumberDelimiter",regNumberDelimiter

Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
Set f = objFSO.CreateTextFile(regInboxPath&filename)
f.write(D.serialize("python")&vbcrlf)
For i = 1 To request.Form("numExportFields")
	If request.Form("exportCheck_"&i) = "on" Then
		f.write(request.Form("exportString_"&i)&vbcrlf)
	End if
next
f.close
Set f = Nothing
Set objFSO = Nothing
Set D = nothing
%>