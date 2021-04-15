<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<%
'The purpose of this script is to determine whether or not a structure has changed.  Used exclusivly in the compound tracking workflow.

''if this script does not work get fragment cdxml and open chemdraw via comm to get the mol3000 for the current experiment molData/structureData DONE
experimentId = request("experimentId")
fragmentId = request("fragmentId")
prefix = request("prefix")
'set appropriate table name
Select Case prefix
	Case "r"
		tableName = "reactants"
	Case "rg"
		tableName = "reagents"
	Case "s"
		tableName = "solvents"
	Case "p"
		tableName = "products"
End Select

Function getInChiKey(molData)
	'use jchem rest web services to get the InChiKey for the specified molData
	Set d = JSON.parse("{}")
	d.Set "structure", molData
	d.Set "parameters", "InChiKey"
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
	getInChiKey = r.Get("structure")
End function

'Function getSmiles(molData)
'	'use jchem rest web services to get the cxsmiles for the specified molData
'	Set d = JSON.parse("{}")
'	d.Set "structure", molData
'	d.Set "parameters", "cxsmiles"
'	data = JSON.stringify(d)
'	Set http = CreateObject("MSXML2.ServerXMLHTTP")
'	http.setOption 2, 13056
'	http.open "POST",chemAxonMolExportUrl,False
'	http.setRequestHeader "Content-Type","application/json" 
'	http.setRequestHeader "Content-Length",Len(data)
'	http.SetTimeouts 120000,120000,120000,120000
'	http.send data
'	Set r = JSON.parse(http.responseText)
'	getSmiles = r.Get("structure")
'End function

Function getInChiKeyFromNode(theNode)
	'get smiles from a cdxml fragment

	'make blank cdxml with the fragment/node data
	fragmentXML = "<?xml version=""1.0"" encoding=""UTF-8"" ?><!DOCTYPE CDXML SYSTEM ""http://www.cambridgesoft.com/xml/cdxml.dtd"" ><CDXML><page>"&theNode.xml&"</page></CDXML>"

	'convert structure data to mol3000 data using jchem
    Set d = JSON.parse("{}")
	fragmentXML = Replace(fragmentXML,"�","&#8226;")
    d.Set "structure", fragmentXML
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

	'get InChiKey from generated moldata
	getInChiKeyFromNode = getInChiKey(molData)
	doc.Close()
	Set doc = Nothing
	cdx.quit()
	Set cdx = Nothing
End Function 

call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id FROM experiments WHERE id="&SQLClean(experimentId,"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")
rec.open strQuery,conn,0,-1
'only experiment owner can run this check
If Not rec.eof Then
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT cxsmiles, molData3000, molData FROM "&tableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND fragmentId="&SQLClean(fragmentId,"N","S")
	rec2.open strQuery,conn,0,-1
	'get the associated molecule by fragment id
	If Not rec2.eof Then
		If Not IsNull(rec2("cxsmiles")) And Not rec2("cxsmiles") = "" Then
			'if cxsmiles were generated, use them
			oldSmiles = getInChiKey(rec2("cxsmiles"))
		Else
			If Not IsNull(rec2("molData3000")) And Not rec2("molData3000") = "" Then
				'if mol3000 data was generated get smiles from mol3000 data
				molData = rec2("molData3000")
				oldSmiles = getInChiKey(molData)
			else
				If Not IsNull(rec2("molData")) And Not rec2("molData") = "" Then
					'otherwise us mol2000 data
					molData = rec2("molData")
					oldSmiles = getInChiKey(molData)
				End if
			End if
		End if
	End If
	rec2.close
	Set rec2 = Nothing

	If oldSmiles = "" Then
		'if we have not been able to get the smiles any other way get the smiles from the reaction cdxml
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT cdx from experiments WHERE id="&SQLClean(experimentId,"N","S")
		rec2.open strQuery,conn,0,-1
		If Not rec2.eof Then
			'unescape cdxml
			cdx = Replace(rec2("cdx"),"\""","""")
			If isnull(cdx) Then
				cdx = ""
			End If
			
			'remove doctype
			Set RegEx = New regexp
			RegEx.Pattern = "<!DOCTYPE[^>]*>"
			RegEx.Global = True
			RegEx.IgnoreCase = True
			cdx = RegEx.Replace(cdx,"")
			Set RegEx = nothing

			'loop through cdxml to get the fragment or group node by fragment id
			Set xml = Server.CreateObject("Microsoft.XMLDOM")
			xml.LoadXML(cdx)
			For Each oNode In xml.getElementsByTagName("fragment")
				If Not IsNull(oNode.getAttribute("id")) Then
					If CStr(oNode.getAttribute("id")) = CStr(fragmentId) Then
						oldSmiles = getInChiKeyFromNode(oNode)
					End if
				End if
			next
			For Each oNode In xml.getElementsByTagName("group")
				If Not IsNull(oNode.getAttribute("id")) Then
					If CStr(oNode.getAttribute("id")) = CStr(fragmentId) Then
						oldSmiles = getInChiKeyFromNode(oNode)
					End if
				End if
			next
		End if
		rec2.close
		Set rec2 = nothing
	End if

	'convert structure data to mol3000 data using jchem
    Set d = JSON.parse("{}")
    d.Set "structure", structureData
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


	'this is a mapping for smiles that should be treated as identical
	override = False
	If experimentId=152080 And oldSmiles="[Na].OC([O-])=O" Then
		override = true
	End If
	If newSmiles = "[OH-].[NaH]" And oldSmiles = "[OH-].[Na]" Then
		override = true
	End if
	If newSmiles = "[NaH].OC([O-])=O" And oldSmiles = "[Na].OC([O-])=O" Then
		override = true
	End if
	If newSmiles = "Cl.[2H]N([2H])C" And oldSmiles = "CN(C)C=O" Then
		override = true
	End if

	
	'log data to files
	If 1=1 Then
		path = "c:\compound_tracking_changed"
		a = recursiveDirectoryCreate("c:\",path)
		fString = vbcrlf&vbcrlf&vbcrlf
		fString = fString & "New Smiles: "&newSmiles&vbcrlf
		fString = fString & "Old Smiles: "&oldSmiles&vbcrlf
		If newSmiles <> oldSmiles Then
			changed = True
		Else
			changed = false
		End if
		fString = fString & "Changed: "&changed&vbcrlf 
		fString = fString & "override: "&override&vbcrlf 
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		set f=fs.OpenTextFile(path&"\"&experimentId&".txt",8,true)
		f.write(fString)
		f.close()
		set f=nothing
		set fs=nothing
	End if

	If newSmiles <> oldSmiles And Not override Then
		'if the smiles are different
		response.write("true")
	Else
		'if the smiles are not different
		response.write("false")
	End if
End if
rec.close
Set rec = nothing
call disconnect
%>