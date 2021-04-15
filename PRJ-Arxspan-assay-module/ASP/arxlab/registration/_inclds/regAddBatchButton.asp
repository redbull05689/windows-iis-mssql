<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
Call getconnectedJchemReg
If hasStructure then
	Set abRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM customFields WHERE UPPER(formName)='STEREOCHEMISTRY'"
	abRec.open strQuery,jchemRegConn,3,3
	If Not abRec.eof then
		stereoField = abRec("actualField")
		abrec.close
		strQuery = "SELECT "&stereoField&" FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(theCdId,"N","S")
		abRec.open strQuery,jchemRegConn,3,3
		If Not abRec.eof then
			stereoValue = abRec(stereoField)
		End if

		jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
		thisMol = CX_cdIdSearch(jChemRegDB,regMoleculesTable,SQLClean(theCdId,"N","S"),"mol:V3")
		Set thisMolObj = JSON.parse(thisMol)
		If IsObject(thisMolObj) Then
			Set structureData = thisMolObj.Get("structureData")
			If IsObject(structureData) And structureData.Exists("structure") Then
				molData = structureData.Get("structure")
			End If
		End If
	End if
	abRec.close
	Set abRec = nothing
	'If isInteger(Left(Trim(Split(molData,vblf)(2)),1)) Then
	'	molData = vbcrlf & molData
	'End if
End if
%>

<form action="addStructure.asp?inFrame=&sourceId=1&groupId=<%=groupId%>" method="post" id="addBatchButton_view">
<select name="Stereochemistry" id="Stereochemistry" style="display:none;">
	<option value="<%=stereoValue%>" selected><%=stereoValue%></option>
</select>
<%
If hasStructure then
	molDataLines = Split(molData,vbcrlf)
	If UBound(molDataLines) = 0 Then
		molDataLines = Split(molData,vbcr)
	End If
	If UBound(molDataLines) = 0 Then
		molDataLines = Split(molData,vblf)
	End If
	If UBound(molDataLines) >= 3 Then
		If Not isInteger(Trim(Left(molDataLines(3),3))) Then
			molData = vbcrlf & molData
		End If
	End if
End if
%>
<input type="hidden" name="regMolData" id="regMolData" value="<%=Server.HTMLEncode(replace(molData, """", "&quot;"))%>">
<input type="hidden" name="addStructureCdxmlData" id="addStructureCdxmlData" value="<%=Server.HTMLEncode(replace(molData, """", "&quot;"))%>">
<input type="hidden" name="addBatch" id="addBatch" value="1">
<input type="hidden" name="fromAddBatchButton" id="fromAddBatchButton" value="1">
<%If theCdId <> "" then%>
<input type="hidden" name="addBatchCdId" id="addBatchCdId" value="<%=theCdId%>">
<%End if%>
<%If Not hasStructure Then
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM groupCustomFieldFields WHERE isIdentity=1 and groupId="&SQLClean(groupId,"N","S")
rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery2 = "SELECT "&SQLClean(rec("actualField"),"TP","S")&" FROM "&regMoleculesTable&" WHERE just_reg="&SQLClean(regNumber,"T","S")&" AND just_batch="&SQLClean(padWithZeros(0,regBatchNumberLength),"T","S")&" AND groupId="&SQLClean(groupId,"N","S")
	rec2.open strQuery2,jchemRegConn,3,3
	theValue = rec2(CStr(rec("actualField")))
	%>
	<input type="hidden" name="<%=rec("formName")%>" value="<%=theValue%>">
	<%
	rec2.close
	Set rec2 = nothing
	rec.movenext
Loop
rec.close
Set rec=nothing
%>
<%End if%>
<%
'TODO: add support for salts
%>
<input type="hidden" name="addStructureSubmit" id="addStructureSubmit" value="1">
<input type="submit" name="addStructureSubmitNewBatchFromShowReg" id="addStructureSubmitNewBatchFromShowReg" value="<%=addBatchText%>" onClick="document.getElementById('addStructureSubmitNewBatchFromShowReg').disabled=true;document.getElementById('addStructureSubmitNewBatchFromShowReg').value='WAIT';document.getElementById('addBatchButton_view').submit();">
</form>