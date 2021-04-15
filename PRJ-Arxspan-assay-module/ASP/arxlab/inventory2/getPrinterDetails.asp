<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%
userPrinter = request.querystring("userPrinter")
printerList = request.querystring("printerList")
printerName = request.querystring("printerName")
updatedPrinterName = request.querystring("updatedPrinterName")

usersTable = getDefaultSingleAppConfigSetting("usersTable")
Call getconnected

If userPrinter Then
	defaultPrinterName = ""
	Set uRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT labelPrinterId FROM "&usersTable&" WHERE id="&SQLClean(session("userId"),"N","S")
	uRec.open strQuery,conn,3,3
	If Not uRec.eof Then
		'User has default printer selected
		Set pRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT printerName FROM labelPrinterSettings WHERE id="&SQLClean(uRec("labelPrinterId"),"N","S")& " AND companyId="&SQLClean(session("companyId"),"N","S")
		pRec.open strQuery,conn,3,3
		If Not pRec.eof Then
			defaultPrinterName = pRec("printerName")
		End If
	End If
	uRec.close
	Set uRec = nothing
	pRec.close
	Set pRec = nothing
	response.write(defaultPrinterName)
ElseIf printerList Then
	Dim pList : pList = array()
	Set pRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT printerName FROM labelPrinterSettings WHERE companyId="&SQLClean(session("companyId"),"N","S")
	pRec.open strQuery,conn,3,3
	Do While Not pRec.eof
		ReDim Preserve pList(UBound(pList) + 1)
		pList(UBound(pList)) = pRec("printerName")
		pRec.movenext
	Loop
	pRec.close
	Set pRec = nothing
	restxt = ""
	If UBound(pList) >= 0 Then
		For i = 0 to UBound(pList)
		   restxt = restxt & "" & pList(i) & ","
		Next    
		restxt = left(restxt,len(restxt)-1)
    End If
    response.write restxt
'response.write pList
ElseIf printerName <> "" Then
	restxt = ""
	Set pdRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT printerType, printerPort, printerIp, printerName FROM labelPrinterSettings WHERE printerName= "&SQLClean(printerName,"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
	pdRec.open strQuery,conn,3,3
	If Not pdRec.eof Then
		restxt = "{""printerType"": """&pdRec("printerType")&""", ""printerPort"": """&pdRec("printerPort")&""", ""printerName"": """&pdRec("printerName")&"""		, ""printerIp"": """&pdRec("printerIp")&"""}"
	End If
	pdRec.close
	Set pdRec = nothing
	Response.Write restxt
	
ElseIf updatedPrinterName <> "" Then
	Set lRec = server.CreateObject("ADODB.RecordSet")
	'Get the printerid for the corresponding printer
	strQuery = "SELECT id FROM labelPrinterSettings WHERE printerName="&SQLClean(updatedPrinterName,"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
	lRec.open strQuery,conn,3,3
	If Not lRec.eof Then
		response.write lRec("id")
		'Check if the user has a default printer
		Set uRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT labelPrinterId FROM "&usersTable&" WHERE id="&SQLClean(session("userId"),"N","S")
		uRec.open strQuery,conn,3,3
		If Not uRec.eof and (Isnull(uRec("labelPrinterId")) or uRec("labelPrinterId") = "") Then
			'Update the users table with the printer selected **only if its not set already
			strQuery = "UPDATE "&usersTable&" set labelPrinterId="&SQLClean(lRec("id"),"N","S")& " WHERE id="&SQLClean(session("userId"),"N","S")
			connAdm.execute(strQuery)
			response.write "Default printer updated Successfully"
		End If
	End If
	uRec.close
	Set uRec = nothing
	lRec.close
	Set lRec = nothing
End If
%>