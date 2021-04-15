<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
regNumber = request.querystring("regNumber")

Set r = JSON.parse("[]")

Call getconnectedJchemReg
foundIt = False

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT cd_id,groupId,parent_cd_id,just_reg,just_batch FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(regNumber,"T","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	foundIt = True
	isBatch = True
Else
	rec.close
End If
If Not foundIt then
	strQuery = "SELECT cd_id,groupId,parent_cd_id,just_reg,just_batch FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(regNumber&regBatchNumberDelimiter&padWithZeros(0,regBatchNumberLength),"T","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		foundIt = True
		isBatch = False
	Else
		rec.close
	End if
End if
If Not foundIt Then
	r.Set "Error","Registration Item not found"
	response.write(JSON.stringify(r))
	response.end
End if
theCdId = rec("cd_id")
theParentCdId = rec("parent_cd_id")
groupId = rec("groupId")
regNumber = rec("just_reg")
batchNumber = rec("just_batch")
If Not IsNull(groupId) Then
	If groupId <> "0" then
		isGroup = True
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
		If session("regRestrictedGroups") <> "" Then
			strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
		End if
		rec2.open strQuery,jchemRegConn,3,3
		If Not rec2.eof Then
			a = ""
		Else
			r.Set "Error","Group does not exist or you are not authorized to access it."
			message = "Group does not exist or you are not authorized to access it."
			response.write(JSON.stringify(r))
			response.end
		End If
		rec2.close
		Set rec2 = nothing
	End if
End if
rec.close
Set rec = Nothing

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(theCdId,"N","S")
rec.open strQuery,jchemRegConn,0,-1

Set rec2 = server.CreateObject("ADODB.RecordSet")
If isGroup Then
	If isBatch then
		strQuery = "SELECT * FROM groupCustomFieldFields WHERE showBatch=1 and groupId="&SQLClean(groupId,"N","S")&" ORDER BY ID ASC"
	Else
		strQuery = "SELECT * FROM groupCustomFieldFields WHERE showCompound=1 and groupId="&SQLClean(groupId,"N","S")&" ORDER BY ID ASC"
	End if
Else
	If isBatch then
		strQuery = "SELECT * FROM customFields WHERE showBatch=1 ORDER BY ID ASC"
	Else
		strQuery = "SELECT * FROM customFields WHERE showCompound=1 ORDER BY ID ASC"
	End if
End If
rec2.open strQuery,jchemRegConn,3,3
Do While Not rec2.eof
	theVal = rec(CStr(rec2("actualField")))
	If theVal = "-1" Then
		theVal = ""
	End If
	Set a = JSON.parse("{}")
	a.Set "fieldName",CStr(rec2("displayName"))
	a.Set "fieldValue",theVal
	r.push(a)
	rec2.moveNext
loop
response.write(JSON.stringify(r))
rec2.close
Set rec2 = Nothing
rec.close
Set rec = nothing

Call disconnectJchemReg
%>