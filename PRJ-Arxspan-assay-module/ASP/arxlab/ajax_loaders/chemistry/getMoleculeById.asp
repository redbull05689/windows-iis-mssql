<%@Language="VBScript" CodePage = 65001 %>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
Response.CharSet = "UTF-8"
Response.CodePage = 65001
server.scriptTimeout = 10000
%>
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../_inclds/globals.asp"-->
<!-- #include file="../../_inclds/common/asp/lib_Jchem.asp"-->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_decodeBase64.asp"-->
<!-- #include file="../../_inclds/experiments/common/functions/fnc_applyChemDrawStyles.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
chemAxonAllMoleculesTable = getCompanySpecificSingleAppConfigSetting("chemAxonAllMoleculesTable", session("companyId"))
chemAxonAllReactionsTable = getCompanySpecificSingleAppConfigSetting("chemAxonAllReactionsTable", session("companyId"))
chemAxonDatabaseName = getCompanySpecificSingleAppConfigSetting("chemAxonDatabaseName", session("companyId"))
blankCdxName = getCompanySpecificSingleAppConfigSetting("blankCdxName", session("companyId"))

returnedSomething = False
tagId = request.querystring("tagId")
sketchId = request.querystring("id")
format = request.querystring("source")
doOverride = request.querystring("override")

strQuery = "SELECT chemicalSketch, format, cd_id FROM liveEditStructureDiagrams WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")&" AND tagId="&SQLClean(tagId,"T","S")&" AND id="&SQLClean(sketchId,"N","S")
Set aRec = server.CreateObject("ADODB.recordset")
aRec.open strQuery,conn,3,3

If Not aRec.eof Then
	If format = aRec("format") Then
		returnedSomething = True
		response.write(aRec("chemicalSketch"))
	Else
		isReaction = CX_isReaction(chemAxonDatabaseName,chemAxonAllMoleculesTable,molData)

		dataTable = chemAxonAllMoleculesTable
		If isReaction Then
			dataTable = chemAxonAllReactionsTable
		End If

		cxResp = CX_getStructureByCdId(chemAxonDatabaseName,dataTable,aRec("cd_id"),format)
		if cxResp = "{}" and LCase(format) = "cdxml" Then
			cxResp = CX_getStructureByCdId(chemAxonDatabaseName,dataTable,aRec("cd_id"),"cdx")
		end if
		Set cxJson = JSON.parse(cxResp)
		If IsObject(cxJson) Then
			If cxJson.Exists("structure") Then
				returnedSomething = True
				If format = "mol" Then
					response.write(cxJson.Get("structure"))
				ElseIf format = "cdx" Or format = "cdxml" Then
					response.write(applyStyles(cxJson.Get("structure"), blankCdxName, ""))
				End If
			End If
		End If
	End If
End If

If (Not returnedSomething) And doOverride = "true" Then
	If format = "mol" Then
		returnedSomething = True
		response.write("Untitled Document-1"&vbcrlf&"  Arxspan"&vbcrlf&vbcrlf&"  0  0  0     0  0              0 V3000"&vbcrlf&"M  V30 BEGIN CTAB"&vbcrlf&"M  V30 COUNTS 0 0 0 0 0"&vbcrlf&"M  V30 BEGIN ATOM"&vbcrlf&"M  V30 END ATOM"&vbcrlf&"M  V30 END CTAB"&vbcrlf&"M  END"&vbcrlf)
	End If
	
	If format = "cdxml" Then
		returnedSomething = True
		response.write("<?xml version=""1.0"" encoding=""UTF-8"" ?>"&vbcrlf&"<!DOCTYPE CDXML SYSTEM ""http://www.cambridgesoft.com/xml/cdxml.dtd"" >"&vbcrlf&"<CDXML"&vbcrlf&" CreationProgram=""ChemDraw 12.0.2.1076"""&vbcrlf&" Name=""Untitled Document-1"""&vbcrlf&" BoundingBox=""0 0 0 0"""&vbcrlf&" WindowPosition=""0 0"""&vbcrlf&" WindowSize=""0 1073741824"""&vbcrlf&" WindowIsZoomed=""yes"""&vbcrlf&" FractionalWidths=""yes"""&vbcrlf&" InterpretChemically=""yes"""&vbcrlf&" ShowAtomQuery=""yes"""&vbcrlf&" ShowAtomStereo=""no"""&vbcrlf&" ShowAtomEnhancedStereo=""yes"""&vbcrlf&" ShowAtomNumber=""no"""&vbcrlf&" ShowBondQuery=""yes"""&vbcrlf&" ShowBondRxn=""yes"""&vbcrlf&" ShowBondStereo=""no"""&vbcrlf&" ShowTerminalCarbonLabels=""no"""&vbcrlf&" ShowNonTerminalCarbonLabels=""no"""&vbcrlf&" HideImplicitHydrogens=""no"""&vbcrlf&" LabelFont=""3"""&vbcrlf&" LabelSize=""10"""&vbcrlf&" LabelFace=""96"""&vbcrlf&" CaptionFont=""4"""&vbcrlf&" CaptionSize=""12"""&vbcrlf&" HashSpacing=""2.7"""&vbcrlf&" MarginWidth=""2"""&vbcrlf&" LineWidth=""1"""&vbcrlf&" BoldWidth=""4"""&vbcrlf&" BondLength=""30"""&vbcrlf&" BondSpacing=""12"""&vbcrlf&" ChainAngle=""120"""&vbcrlf&" LabelJustification=""Auto"""&vbcrlf&" CaptionJustification=""Left"""&vbcrlf&" AminoAcidTermini=""HOH"""&vbcrlf&" ShowSequenceTermini=""yes"""&vbcrlf&" ShowSequenceBonds=""yes"""&vbcrlf&" PrintMargins=""36 36 36 36"""&vbcrlf&" MacPrintInfo=""000300000258025800000000190012D0FF9CFF721964135E0367052803FC000200000258025800000000190012D0000100000064000000010001010100000001270F000100010000000000000000000000000002001901900000000000600000000000000000000100000000000000000000000000000000"""&vbcrlf&" color=""0"""&vbcrlf&" bgcolor=""1"""&vbcrlf&"><colortable>"&vbcrlf&"<color r=""1"" g=""1"" b=""1""/>"&vbcrlf&"<color r=""0"" g=""0"" b=""0""/>"&vbcrlf&"<color r=""1"" g=""0"" b=""0""/>"&vbcrlf&"<color r=""1"" g=""1"" b=""0""/>"&vbcrlf&"<color r=""0"" g=""1"" b=""0""/>"&vbcrlf&"<color r=""0"" g=""1"" b=""1""/>"&vbcrlf&"<color r=""0"" g=""0"" b=""1""/>"&vbcrlf&"<color r=""1"" g=""0"" b=""1""/>"&vbcrlf&"</colortable><fonttable>"&vbcrlf&"<font id=""3"" charset=""iso-8859-1"" name=""Arial""/>"&vbcrlf&"<font id=""4"" charset=""iso-8859-1"" name=""Times New Roman""/>"&vbcrlf&"</fonttable><page"&vbcrlf&" id=""3"""&vbcrlf&" BoundingBox=""0 0 540 720"""&vbcrlf&" HeaderPosition=""36"""&vbcrlf&" FooterPosition=""36"""&vbcrlf&" PrintTrimMarks=""yes"""&vbcrlf&" HeightPages=""1"""&vbcrlf&" WidthPages=""1"""&vbcrlf&"/></CDXML>")
	End If
	
	If format = "cdx" Then
		returnedSomething = True
		response.write("VmpDRDAxMDAEAwIBAAAAAAAAAAAAAACAAAAAAAMAFgAAAENoZW1EcmF3IDEyLjAuMi4xMDc2CAAV")
		response.write("AAAAZGV2ZWxvcG1lbnQtY2R4LmNkeAQCEAAAAAAAAAAAAAAAAAAAAAAAAQkIAAAAAAAAAAAAAgkI")
		response.write("AABAowEAAPoCAAkAAA0IAQABCAcBAAE6BAEAATsEAQAARQQBAAE8BAEAAAwGAQABDwYBAAENBgEA")
		response.write("AEIEAQAAQwQBAABEBAEAAAoICAADAGAAyAADAAsICAAEAAAA8AADAAkIBAAzswIACAgEAAAAAgAH")
		response.write("CAQAAAABAAYIBAAAAAQABQgEAAAAHgAECAIAeAADCAQAAAB4ACMIAQAFDAgBAAAoCAEAASkIAQAB")
		response.write("KggBAAECCBAAAAAkAAAAJAAAACQAAAAkAAEDAgAAAAIDAgABAAADMgAIAP///////wAAAAAAAP//")
		response.write("AAAAAP////8AAAAA//8AAAAA/////wAAAAD/////AAD//wABJAAAAAIAAwDkBAUAQXJpYWwEAOQE")
		response.write("DwBUaW1lcyBOZXcgUm9tYW4ACHgAAAMAAAJYAlgAAAAAGQAS0P+c/3IZZBNeA2cFKAP8AAIAAAJY")
		response.write("AlgAAAAAGQAS0AABAAAAZAAAAAEAAQEBAAAAAScPAAEAAQAAAAAAAAAAAAAAAAACABkBkAAAAAAA")
		response.write("YAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAYADAAAABAIQAAAAAAAAAAAAAADQAgAAHAIWCAQA")
		response.write("AAAkABgIBAAAACQAGQgAABAIAgABAA8IAgABAAAAAAAAAA==")
	End If
End If

response.end()
%>