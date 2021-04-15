<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
sectionId = "reg"
subSectionId = "sd-rollback"
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If

rollbackId = request.querystring("id")
session("rollbackId") = request.querystring("id")
session("rollBackCdIds") = ""

' 5266: The rollback process has been rewritten such that user can select either compound or batch for rollback but not both.
If request.querystring("compounds") = "1" Then
	compounds = True
Else
	compounds = False
End if
If request.querystring("batches") = "1" Then
	batches = True
Else
	batches = False
End if

If Not compounds And Not batches Then
	response.redirect("show-bulk-file-list.asp")
End If

Call getconnectedJchemReg

If session("regRegistrar") And session("regRegistarRestricted") then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM sdImports WHERE id="&SQLClean(rollBackId,"N","S")&" AND userId="&SQLClean(session("userId"),"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If rec.eof Then
		rec.close
		Set rec = nothing
		Call disconnectJchemReg
		response.redirect("logout.asp")
	End If
	rec.close
	Set rec = nothing
End if

If compounds then
	cdIdStr = ""
	Set rec = server.CreateObject("ADODB.RecordSet")
	'find batches that are children of the compounds in this file
	strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE just_batch<>'"&compoundBatchNumber&"' AND parent_cd_id in (SELECT cd_id from "&regMoleculesTable&" WHERE arxspan_sd_source_id="&SQLClean(rollBackId,"N","S")&" AND just_batch='"&compoundBatchNumber&"')"
	rec.open strQuery,jchemRegConn,0,-1
	If Not rec.eof Then
		childError = true
		message = 1
		Do While Not rec.eof
			If cdIdStr <> "" Then
				cdIdStr = cdIdStr & ","
			End if
			cdIdStr = cdIdStr & rec("cd_id")
			rec.moveNext
		Loop
	Else
		message = 2
	End If
	rec.close

	' now get the compounds
	strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE arxspan_sd_source_id="&SQLClean(rollBackId,"N","S") & ";"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		If cdIdStr <> "" Then
			cdIdStr = cdIdStr & ","
		End if
		cdIdStr = cdIdStr & rec("cd_id")
		rec.moveNext
	Loop
	rec.close

	Set rec=Nothing
Else ' If batches Then
	message = 2
	cdIdStr = ""
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT cd_id FROM "&regMoleculesTable&" WHERE arxspan_sd_source_id="&SQLClean(rollBackId,"N","S") & " AND just_batch<>'"&compoundBatchNumber&"';"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		cdIdStr = cdIdStr & rec("cd_id")
		rec.moveNext
		If Not rec.eof Then
			cdIdStr = cdIdStr & ","
		End if
	Loop
End If

session("rollbackCdIds") = cdIdStr
Call disconnectJchemReg

redirectUrl = "SDRollBackResults.asp?m="&message&"&id="&rollBackId
If compounds Then
	redirectUrl = redirectUrl & "&type=compounds"
Else
	redirectUrl = redirectUrl & "&type=batches"
End If
response.redirect(redirectUrl)
%>