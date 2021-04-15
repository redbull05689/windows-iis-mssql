<%@Language="VBScript" CodePage = 65001 %>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
	Response.CharSet = "UTF-8"
	Response.CodePage = 65001

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
		If revisionNumber = "" And (session("hasInventoryIntegration") Or session("hasCompoundTracking") Or session("hasBarcodeChooser")) And ownsExperiment("1",experimentId,session("userId")) Then
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
	If attachment = "" then
		response.addheader "Content-Disposition", "inline; " & "filename="&Replace(cleanFileName(rec("name")), ",", " ")&"-reaction.cdxml"
	Else
		response.addheader "Content-Disposition", "attachment; " & "filename="&Replace(cleanFileName(rec("name"))," ","_")&"-reaction.cdxml"
	End if
	'Response.AddHeader "Content-Length", Len(cdxData)
	
	'send a blank cdx file if there is no cdx data 
	If Len(cdxData) = 0 Then
		cdxData = "<?xml version=""1.0""  ?><!DOCTYPE CDXML SYSTEM ""http://www.cambridgesoft.com/xml/cdxml.dtd"" ><CDXML CreationProgram=""ChemDraw 12.0.2.1076"" BoundingBox=""0 0 0 0"" WindowPosition=""-1073741824 0"" WindowSize=""1073741824 1073741824"" FractionalWidths=""yes"" InterpretChemically=""yes"" ShowAtomQuery=""yes"" ShowAtomStereo=""no"" ShowAtomEnhancedStereo=""yes"" ShowAtomNumber=""no"" ShowBondQuery=""yes"" ShowBondRxn=""yes"" ShowBondStereo=""no"" ShowTerminalCarbonLabels=""no"" ShowNonTerminalCarbonLabels=""no"" HideImplicitHydrogens=""no"" LabelFont=""3"" LabelSize=""10"" LabelFace=""96"" CaptionFont=""3"" CaptionSize=""10"" HashSpacing=""2.5"" MarginWidth=""1.6"" LineWidth=""0.6"" BoldWidth=""2"" BondLength=""14.4"" BondSpacing=""18"" ChainAngle=""120"" LabelJustification=""Auto"" CaptionJustification=""Left"" AminoAcidTermini=""HOH"" ShowSequenceTermini=""yes"" ShowSequenceBonds=""yes"" PrintMargins=""36 36 36 36"" MacPrintInfo=""0003000001200120000000000B6608A0FF84FF880BE309180367052703FC0002000001200120000000000B6608A0000100640064000000010001010100000001270F000100010000000000000000000000000002001901900000000000600000000000000000000100000000000000000000000000000000"" color=""0"" bgcolor=""1""><colortable><color r=""1"" g=""1"" b=""1""/><color r=""0"" g=""0"" b=""0""/><color r=""1"" g=""0"" b=""0""/><color r=""1"" g=""1"" b=""0""/><color r=""0"" g=""1"" b=""0""/><color r=""0"" g=""1"" b=""1""/><color r=""0"" g=""0"" b=""1""/><color r=""1"" g=""0"" b=""1""/></colortable><fonttable><font id=""3"" charset=""iso-8859-1"" name=""Arial""/></fonttable><page id=""128"" BoundingBox=""0 0 540 719.75"" HeaderPosition=""36"" FooterPosition=""36"" PrintTrimMarks=""yes"" HeightPages=""1"" WidthPages=""1""/></CDXML>"
	End If
	response.write(cdxData)
End if
%>