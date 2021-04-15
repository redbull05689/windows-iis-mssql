<!-- #include virtual="/_inclds/sessionInit.asp" -->
<script language="JScript" src="encodeStr.asp" runat="server"></script>
<%
sectionId="reg"
Response.CodePage = 65001    
Response.CharSet = "utf-8"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/fnc_regChangeStatus.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include file="_inclds/fnc_sendProteinToSearchTool.asp"-->
<!-- #include file="_inclds/fnc_removeCdIdsFromFT.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
Response.CodePage = 65001    
Response.CharSet = "utf-8"

isBatchForAdd = True
%>
<!-- #include file="_inclds/inventoryPopup.asp"-->


<%
wholeRegNumber = request.querystring("regNumber")
%>

<%
moleculeAddedText = "Molecule Added"
addAnotherStructureText = "ADD ANOTHER STRUCTURE"
addBatchText = "ADD BATCH"

hasRegSorting = checkBoolSettingForCompany("allowRegistrationSorting", session("companyId"))
dontUseParentCdId = checkBoolSettingForCompany("disallowParentCdId", session("companyId"))
jChemRegDB = getCompanySpecificSingleAppConfigSetting("jChemRegDataBaseName", session("companyId"))
regBatchNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regBatchNumberDelimiter", session("companyId"))
regSaltMappingTable = getCompanySpecificSingleAppConfigSetting("regSaltMappingTable", session("companyId"))
regSaltsView = getCompanySpecificSingleAppConfigSetting("regSaltMappingView", session("companyId"))
regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
projectFieldInReg = checkBoolSettingForCompany("useProjectFieldInReg", session("companyId"))
regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
polymer = getCompanySpecificSingleAppConfigSetting("polymer", session("companyId"))

Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT cd_id,groupId,parent_cd_id,just_reg,just_batch,projectId,reg_id FROM " & regMoleculesTable & " WHERE reg_id="&SQLClean(wholeRegNumber,"T","S")
rec.open strQuery,jchemRegConn,3,3

If rec.eof Then
	title = "Error"
	message = "Unable to locate: " & wholeRegNumber
	response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
End If

theRegId = rec("reg_id")
theCdId = rec("cd_id")
theParentCdId = rec("parent_cd_id")
groupId = rec("groupId")
projectId = rec("projectId")
regNumber = rec("just_reg")
batchNumber = rec("just_batch")
hasStructure = True
allowBatchesOfBatches = False
allowBatches = True
imageWidth = "300"
imageHeight = "300"
useSalts = True

batchZeroPos = InStrRev(theRegId, "-00")
If batchZeroPos = (Len(theRegId) - 2) Then
	theRegId = Left(theRegId, batchZeroPos - 1)
End If

groupPrefix = ""

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
			If rec2("hasStructure") = 0 Then
				hasStructure = False
			End if	
			If rec2("allowBatchesOfBatches") = 1 Then
				allowBatchesOfBatches = True
			End If
			If rec2("allowBatches") = 0 Then
				allowBatches = False
			End If
			If rec2("useSalts") <> 1 Then
				useSalts = False
			End If
			If columnExists(rec2,"imageWidth") Then
				If Not IsNull(rec2("imageWidth")) then
					imageWidth = rec2("imageWidth")
				End if
			End If
			If columnExists(rec2,"imageHeight") Then
				If Not IsNull(rec2("imageHeight")) then
					imageHeight = rec2("imageHeight")
				End if
			End If
			groupPrefix = rec2("groupPrefix")
		Else
			title = "Error"
			message = "Group does not exist or you are not authorized to access it."
			response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
		End If
	End if
End if
rec.close
Set rec = nothing
Call disconnectJchemReg

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT distinct name FROM projects WHERE id in (SELECT projectId FROM linksProjectRegView where (cd_id="&SQLClean(theCdId,"N","S")&" OR cd_id="&SQLClean(theParentCdId,"N","S")&") AND companyId="&SQLClean(session("companyId"),"N","S")&") or id in ("&SQLClean(projectId,"N","S")&")"
rec.open strQuery,conn,3,3
projectName = ""
counter = 0
Do While Not rec.eof
	If counter > 0 Then
		projectName = projectName &"<br/>"
	End If
	counter = counter + 1
	projectName = projectName & rec("name")
	rec.movenext
loop
rec.close
Set rec = nothing

On Error Resume next
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM regTemplates WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND groupId="&SQLClean(groupId,"N","S")
strQuery = strQuery & " AND batch=1"
rec.open strQuery,conn,3,3
If Not rec.eof Then
	regHasTemplate = True
End if
If Error.num <> 0 Then
 regHasTemplate = true
End if
On Error goto 0

%>

<%
canViewPage = true
if Not (session("regRegistrar") Or session("regUser")) Then
	canViewPage = False
End If

If session("regRestrictedUser") Then
	canViewPage = False
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT projectId FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1"
	rec.open strQuery,conn,3,3
	projectString = "(0"
	If Not rec.eof Then
		projectString = projectString & ","
	End if
	Do While Not rec.eof
		projectString = projectString & rec("projectId")
		rec.movenext
		If Not rec.eof Then
			projectString = projectString & ","
		End if
	Loop
	projectString = projectString & ")"
	rec.close
	Set rec = Nothing
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM linksProjectRegView where (cd_id="&SQLClean(theCdId,"N","S")& " or cd_id="&SQLClean(theParentCdId,"N","S")&") AND (projectId in "&projectString&" OR parentProjectId in "&projectString&")"
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		canViewPage = True	
	End If
End If

If Not canViewPage Then
	response.redirect(mainAppPath&"/logout.asp")
End if
%>

<%
If request.Form("deleteStructureSubmitted") <> "" Then
	If canDeleteStructureReg then
		Call getconnectedjchemReg
		deleteStructureCdId = request.Form("deleteStructureCdId")
		a = removeCdIdsFromFT(deleteStructureCdId)
		a = CX_removeStructure(jChemRegDB,regMoleculesTable,deleteStructureCdId)
		response.redirect("showReg.asp?regNumber="&left(request.querystring("regNumber"),InstrRev(request.querystring("regNumber"),regBatchNumberDelimiter)-1))
	End if
End If

If (session("regRegistrar") And Not session("regRegistrarRestricted")) Or session("canEditReg") then
	If request.Form("approveSubmit") <> "" Then
		call getconnectedJchemReg
			a = regChangeStatusBatch("approve",request.Form("cdId"))
		call disconnectJchemReg
	End If
	If request.Form("deleteSubmit") <> "" Then
		call getconnectedJchemReg
			a = regChangeStatusBatch("delete",request.Form("cdId"))
		call disconnectJchemReg
	End If
	If request.Form("editSubmit") <> "" Then
		call getconnectedJchemReg
		cdId = request.Form("cd_id")
		userCreated = request.Form("userCreated")
		dateCreated = request.Form("dateCreated")
		source = request.Form("source")
		chemicalName = request.Form("chemicalName")
		molecularFormula = request.Form("molecularFormula")
		molecularWeight = request.Form("molecularWeight")
		exactMass = request.Form("exactMass")
		smiles = request.Form("smiles")
		multiplicity = request.Form("Multiplicity")
		numSalts = request.Form("numSalts")
		existSaltNum = request.Form("existSaltNum")

	
		'5115 add recordUpdated
		updateQuery = "UPDATE "&regMoleculesTable&" SET chemical_name="&SQLClean(chemicalName,"T","S")&","&_
					"cd_formula="&SQLClean(molecularFormula,"T","S")&","&_
					"cd_smiles="&SQLClean(smiles,"T","S")&","&_
					"cd_molweight="&SQLClean(molecularWeight,"T","S")&","&_
					"exact_mass="&SQLClean(exactMass,"N","S")

		usersTable = getDefaultSingleAppConfigSetting("usersTable")
		Set rec = server.CreateObject("ADODB.RecordSet")
		If isGroup Then
			strQuery = "SELECT * FROM groupCustomFieldFields WHERE showBatch=1 and showBatchInput=1 and groupId="&SQLClean(groupId,"N","S")
		else
			strQuery = "SELECT * FROM customFields WHERE showBatch=1"
		End if

		rec.open strQuery,jChemRegConn,3,3
		Do While Not rec.eof
			If rec("dataType")="float" Or rec("dataType")="int" Or rec("dataType")="text" Or rec("dataType")="multi_float" Or rec("dataType")="multi_int" Or rec("dataType")="multi_text" Or rec("dataType")="file" then
				If rec("enforceUnique") Then
					Set uRec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE "&rec("actualField")&"="&SQLClean(Trim(request.Form(rec("formName"))),"T","S")&" AND reg_id <>"&SQLClean(request.querystring("regNumber"),"T","S")
					uRec.open strQuery,jchemRegConn,3,3
					isUnique = true
					If Not uRec.eof Then
						isUnique = False
						regError = True
						errorText = errorText & rec("displayName")&" does not contain a unique value.  <br/>"
					End if
					
					'If isUnique then
					'	updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")
					'End if
				Else
					If Trim(request.Form(rec("formName"))) <> "" then
						If rec("dataType") = "int" Then
							If Not isInteger(Trim(request.Form(rec("formName")))) Then
								regError = True
								errorText = errorText & rec("displayName")&" must be an integer.  <br/>"
								errorFields = errorFields & rec("formName") &","
							End if
						End if

						If rec("dataType") = "float" Then
							If Not isNumber(Trim(request.Form(rec("formName")))) Then
								regError = True
								errorText = errorText & rec("displayName")&" must be an real number.  <br/>"
								errorFields = errorFields & rec("formName") &","
							End if
						End if

						If rec("dataType") = "multi_int" Then
							vals = Split(Trim(request.Form(rec("formName"))),"###")
							For i = 0 To UBound(vals)
								If Not isInteger(vals(i)) Then
									regError = True
									errorText = errorText & rec("displayName")&" item "&(i+1)&" must be an integer.  <br/>"
									errorFields = errorFields & rec("formName") &","
								End If
							next
						End if

						If rec("dataType") = "multi_float" Then
							vals = Split(Trim(request.Form(rec("formName"))),"###")
							For i = 0 To UBound(vals)
								If Not isNumber(vals(i)) Then
									regError = True
									errorText = errorText & rec("displayName")&" item "&(i+1)&" must be an real number.  <br/>"
									errorFields = errorFields & rec("formName") &","
								End if
							next
						End If
					End if
				End If
				If Not regError Then
					If rec("dataType")="text" Then
						updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(Server.htmlEncode(encodeIt(cstr(request.Form(rec("formName"))))),"T","S")
					Else 
						updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")
					End If
				End if
			End if
			If rec("dataType")="date" then
				updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")
			End if
			If rec("dataType")="long_text" then
				updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(Server.htmlEncode(encodeIt(cstr(request.Form(rec("formName"))))),"T","S")
			End if
			If rec("dataType")="drop_down" then
				foundIt = False
				If (request.Form(rec("formName"))="-1" And rec("requireBatch") = 0) And CInt(rec("dropDownId")) <> -99 Then
					foundIt = true
				End If				
				theValue = request.Form(rec("formName"))
				If CInt(rec("dropDownId")) <> -99 then
					Set rec2 = server.CreateObject("ADODB.recordSet")
					strQuery = "SELECT * FROM regDropDownOptions WHERE parentId="&SQLClean(rec("dropDownId"),"N","S")&" ORDER BY value"
					rec2.open strQuery,jchemRegConn,3,3
					Do While Not rec2.eof
						If theValue=rec2("value") Then
							foundIt = true	
						End if
						rec2.movenext
					Loop
					rec2.close
					Set rec2 = nothing
				else
						Set rec2 = Server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT firstName,lastName FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id in("&getUsersICanSee()&")"
						rec2.open strQuery,conn,3,3
						Do While Not rec2.eof
							If theValue =rec2("firstName")&" " &rec2("lastName") Then
								foundIt = true
							End if
							rec2.movenext
						loop
				End if
				If Not foundIt Then
					If CInt(rec("dropDownId")) <> -99 then
						regError = True
						errorText = errorText & rec("displayName")&" is not a valid option.  <br/>"
					End if
				Else
					If Not (CInt(rec("dropDownId")) = -99 And request.Form(rec("formName"))="-1") then
						updateQuery = updateQuery & "," &rec("actualField") &"="& SQLClean(request.Form(rec("formName")),"T","S")						
					Else
						repsonse.write(rec("formName"))
					End if
				End if
			End if
		rec.movenext
		Loop
		rec.close
		Set rec = nothing




i=1
Do While request.Form("salt_"&i&"_cdId") <> "0" and request.Form("salt_"&i&"_cdId") <> "" and i < existSaltNum
' deleting salts
if   request.Form("salt_"&i&"_deleteBtn") = "delete"    then 
  saltUpdateQuery = "DELETE FROM "&regSaltMappingTable&" WHERE id = "&SQLClean(request.Form("salt_"&i&"_Id"),"N","S")
else

' updating salts
saltUpdateQuery = "UPDATE   "&regSaltMappingTable&" SET multiplicity="&SQLClean(Trim(request.Form("salt_"&i&"_multiplicity")),"N","S")&_
                            ",saltId="&SQLClean(request.Form("salt_"&i&"_cdId"),"N","S")&_
                            "WHERE id = "&SQLClean(request.Form("salt_"&i&"_Id"),"N","S")
end if                           
jchemRegConn.execute(saltUpdateQuery)
 i=i+1
Loop

i= existSaltNum+1
Do While request.Form("salt_"&i&"_cdId") <> "0" and request.Form("salt_"&i&"_cdId") <> ""			
 ' inserting new salts
					saltQuery = "INSERT INTO "&regSaltMappingTable&"(saltId,molId,multiplicity) values("&_
							SQLClean(request.Form("salt_"&i&"_cdId"),"N","S")&","&_
							SQLClean(cdId ,"N","S")&","&_
							SQLClean(Trim(request.Form("salt_"&i&"_multiplicity")),"N","S")&")"
												
	jchemRegConn.execute(saltQuery)
	i = i+1
Loop		




		If  Not regError Then
			updateQuery = updateQuery & " WHERE cd_id="&SQLClean(theCdId,"N","S")

			jchemRegConn.execute(updateQuery)



			dateFunction = "GETDATE()"
			dateFunction2 = "GETUTCDATE()"
			strQuery = "UPDATE "&regMoleculesTable&" SET "&_
					"dateLastModified="&dateFunction &","&_
					"dateLastModifiedUTC="&dateFunction2 &","&_
					"userLastModified="&SQLClean(session("firstName")&" "&session("lastName"),"T","S") & "," &_
					"userLastModifiedId="&SQLClean(session("userId"),"N","S") &_
					" WHERE cd_id="&SQLClean(cdId,"N","S")
			jchemRegConn.execute(strQuery)
			strQuery = "INSERT INTO modLog(cd_id,userId,dateModified,dateModifiedUTC,userName) values("&_
					SQLClean(cdId,"N","S")&","&_
					SQLClean(session("userId"),"N","S")&","&_
					dateFunction & "," &_
					dateFunction2 & "," &_
					SQLClean(session("firstName")&" "&session("lastName"),"T","S") &")"
			jchemRegConn.execute(strQuery)
			If session("companyHasFT") Or session("companyHasFTLiteReg") then
				Set http = CreateObject("MSXML2.ServerXMLHTTP")
				http.setOption 2, 13056
				a = sendProteinToSearchTool(theCdId,true,false)
			End if
		End if
	End If
	
End if
%>
<%
sectionId = "reg"
subSectionId = "show-batch"
%>
	<!-- #include file="../_inclds/header-tool.asp"-->
	<!-- #include file="../_inclds/nav_tool.asp"-->

<style type="text/css">@import url(<%=mainAppPath%>/js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.browser.dep.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jquery.printElement.js?<%=jsRev%>"></script>




<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
If isGroup Then
	strQuery = "SELECT * FROM groupCustomFieldFields WHERE showBatch=1 and groupId="&SQLClean(groupId,"N","S")
else
	strQuery = "SELECT * FROM customFields WHERE showBatch=1"
End If
If hasRegSorting Then
	strQuery = strQuery & " ORDER BY sortOrder ASC, id ASC"
Else
	strQuery = strQuery & " ORDER BY id ASC"
End if

fieldsStr = "[""cd_id"",""cd_timestamp"",""userLastModified"",""dateLastModified"",""cd_formula"",""cd_smiles"",""cd_molweight"",""exact_mass"",""chemaxon_chemical_name"",""source"",""name"",""user_name"",""experiment_id"",""revision_number"",""experiment_name"",""is_permanent"",""status_id"",""type_id"",""dateCreatedUTC"",""dateLastModifiedUTC""]"
Set fieldsArr = JSON.parse(fieldsStr)

rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
	fieldsArr.push CStr(rec("actualField"))
	rec.movenext
Loop

recNum = 0
queryFields = ""
Do While recNum < fieldsArr.length
	If queryFields <> "" Then
		queryFields = queryFields & ","
	End If
	
	queryFields = queryFields & fieldsArr.Get(recNum)
	recNum = recNum + 1
Loop

Set regRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT "&queryFields&" FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(theCdId,"N","S")
regRec.open strQuery,jchemRegConn,3,3

foundData = False
Set regJson = JSON.parse("{}")
If Not regRec.eof Then
	recNum = 0
	foundData = True
	Do While recNum < fieldsArr.length
		theVal = regRec(fieldsArr.Get(recNum))
		If IsNull(theVal) Then
			theVal = ""
		End If
		regJson.Set fieldsArr.Get(recNum), theVal
		recNum = recNum + 1
	Loop
End If

regRec.close
Set regRec = Nothing

If Not foundData Then
	response.write("Batch not found")
	response.end()
End If

parentCdid = regJson.Get(fieldsArr.Get(0))
dateCreated = regJson.Get(fieldsArr.Get(1))
userLastModified = regJson.Get(fieldsArr.Get(2))
dateLastModified = regJson.Get(fieldsArr.Get(3))
If hasStructure then
	molecularFormula = regJson.Get(fieldsArr.Get(4))
	If regJson.Get(fieldsArr.Get(5)) <> "" then
		smiles = CX_standardize(aspJsonStringify(Split(regJson.Get(fieldsArr.Get(5))," ")(0)),"smiles",defaultStandardizerConfig,"smiles")
	End If
	If regJson.Get(fieldsArr.Get(6)) <> "" then
		molWeight = Round(regJson.Get(fieldsArr.Get(6)),2)
	End If
	If regJson.Get(fieldsArr.Get(7)) <> "" then
		exactMass = Round(regJson.Get(fieldsArr.Get(7)),2)
	End if
	chemicalName = regJson.Get(fieldsArr.Get(8))
End if
source = regJson.Get(fieldsArr.Get(9))
name = regJson.Get(fieldsArr.Get(10))
userName = regJson.Get(fieldsArr.Get(11))
experimentId = regJson.Get(fieldsArr.Get(12))
revisionNumber = regJson.Get(fieldsArr.Get(13))
experimentName = regJson.Get(fieldsArr.Get(14))
perm = regJson.Get(fieldsArr.Get(15))
statusId = regJson.Get(fieldsArr.Get(16))
experimentType = regJson.Get(fieldsArr.Get(17))
dateCreatedUTC = regJson.Get(fieldsArr.Get(18))
dateLastModifiedUTC = regJson.Get(fieldsArr.Get(19))
lastIndex = 19
%>
<%'412015%>
<!-- #include file="_inclds/regTopRightFunctions.asp"-->
<%'/412015%>
<div id="regWindow" class="registrationPage sideBySideFields compoundPage<%If Not hasStructure then%> noStructureCompoundPage<%End if%>">
<%
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "select cd_id,reg_id from "&regMoleculesTable&" WHERE cd_id="&SQLClean(theParentCdId,"N","S")&" AND parent_cd_id<>0"
rec.open strQuery,jchemRegConn,3,3
If rec.eof then
%>
<a href="showReg.asp?regNumber=<%=left(request.querystring("regNumber"),InstrRev(request.querystring("regNumber"),regBatchNumberDelimiter)-1)%>" class="parentLink">Back to Parent</a>
<%else%>
<a href="showBatch.asp?regNumber=<%=rec("reg_id")%>" class="parentLink">Back to Parent</a>
<%End if%>
<div class="showRegRecordContainer">
<%If hasStructure then%>
<div id="chemicalImage" formname="structureImage" class="reg-chem-image" style="position:absolute;width:<%=imageWidth%>px;height:<%=imageHeight%>px;">
<%response.write(CX_getSvgByCdId(jChemRegDB, regMoleculesTable, regJson.Get("cd_id"), imageWidth, imageHeight))%>
</div>
<%End if%>
<%If allowBatchesOfBatches Then%>
<%addBatchRegNumber=regNumber%>
<!-- #include file="_inclds/regAddBatchButton.asp"-->
<%End if%>

<%If regHasTemplate then%>
<div id="regTemplateHolder"  ></div>
<%End if%>

<div class="regMetaData" style="<%If regHasTemplate then%>display:block;<%End if%>position:relative;" id="regMetaData">
<h1 <%If hasStructure then%><%If imageWidth <= 300 then%>style="margin-left:350px;"<%End if%><%End if%>>Compound Number: <span id="regId_view" class="regFieldData"><%=theRegId%></span></h1>
<div style="display:none;">
<span id="regCompoundNumber_view"><%=theRegId%></span>
</div>
<%If allowBatchesOfBatches Then%>
<%addBatchRegNumber=regNumber%>
<!-- #include file="_inclds/regAddBatchButton.asp"-->
<%End if%>
<form method="POST" action="showBatch.asp?regNumber=<%=request.querystring("regNumber")%>" id="regForm" onsubmit="saveMultis();">
<%If regError then%>
	<span style="color:red;padding-left:5px;"><%=errorText%></span>
<%End if%>
<div id="systemProperties" class="systemProperties" <%If hasStructure then%><%If imageWidth>300 then%>style="margin:<%=imageHeight + 40%>px 0 40px 0px;"<%else%>style="margin:0 0 50px 350px;"<%End if%><%End if%>>
	<div class="item">
		<span class="regFieldName">User Created:</span>
		<span class="regFieldData" id="userCreated_view"><%=userName%></span>
		<input type="hidden" value="<%=parentCdid%>" name="cd_id" id="cd_id">
	</div>
	<div class="item">
		<span class="regFieldName">Date Created:</span>
		<span class="regFieldData" id="dateCreated_view"><%If session("useGMT") then%><%=dateCreatedUTC%><%else%><%=dateCreated%><%End if%></span>
	</div>
	<div class="item">
		<span class="regFieldName">User Modified:</span>
		<span class="regFieldData" id="userLastModified_view"><%=userLastModified%></span>
	</div>
	<div class="item">
		<span class="regFieldName">Date Modified:</span>
		<span class="regFieldData" id="dateModified_view"><%If session("useGMT") then%><%=dateLastModifiedUTC%><%else%><%=dateLastModified%><%End if%></span>
	</div>
	<%If projectName <> "" And projectFieldInReg then%>
	<div class="item">
		<span class="regFieldName">Project:</span>
		<span class="regFieldData" id="projectName_view"><%=projectName%></span>
	</div>
	<%End if%>
	<%If useSalts then%>
	<%
	Set saltRec = server.CreateObject("ADODB.RecordSet")
	thisCdId = parentCdId

	If dontUseParentCdId Then
		thisCdId = theCdId
	End if


	strQuery = "SELECT id, saltId, name, multiplicity FROM "&regSaltsView&" WHERE molId="&SQLClean(thisCdId,"N","S")
	saltRec.open strQuery,jchemRegConn,3,3
	If saltRec.eof Then
		wasEmpty = true
	End if
	%>
	<div id="saltsContainer" class="saltsContainer" <%If hasStructure then%>style="margin-left:0;"<%End if%>>
	<h2>Salts</h2>
	<div id="addSaltsBtn" style="display: none">
	<a href="javascript:void(0);" onClick="addNewSalts()" class="newSalt" style="background-color: #1eb242;color:white; ">ADD SALT+</a>
	</div>
	<%
	numSalts = 0
	Do While Not saltRec.eof
		numSalts = numSalts +1
		
	%>
			<div id="salt_<% =numSalts %>_container"  class = "saltItemContainer">
			<% 'this id value should not be displayed, it is for sql updating %>
			<input type="text" name="salt_<% = numSalts%>_Id"  id="salt_<% = numSalts %>_Id"  value ="<%=saltRec("id")%>" style = "display: none">

			<div id="salt_<% =numSalts %>_display" >
			<div class="inline">
			  <span class="regFieldName">Name:</span>
			  <span class="regFieldData" style="width: 100px;"><%=saltRec("name")%></span>
			</div>
			<div class="inline" >
				<span class="regFieldName">Multiplicity:</span>
				<span class="regFieldData" style="width: 100px;"><%=saltRec("multiplicity")%></span>
			</div>
			</div>

			<div id = "salt_<% =numSalts %>_edit" style="display:none";>
			<label for="salt_<% =numSalts %>_cdId" style="font-weight: bold; padding: 2px; margin: 2px;">Salt</label>
			<select id="salt_<% =numSalts %>_cdId" name="salt_<% =numSalts %>_cdId" <%=selectAutoComplete%>>
			<%
			call getconnectedJchemReg
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT cd_id,name FROM "&regSaltsTable& " WHERE 1=1 ORDER BY upper(name) ASC"
			'rec.open strQuery,jchemRegConn,0,1
			Set rec = jChemRegConn.execute(strQuery)
			Do While Not rec.eof
				'show the selected value as the default value
			%>
				<option value="<%=rec("cd_id")%>"   
				  <% if   rec("cd_id") = saltRec("saltId")   then%>
					  selected="selected"
					<% end if %>
				  ><%=rec("name")%>	
				</option>
			<%
				rec.movenext
			Loop
			rec.close
			Set rec = nothing
			Call disconnectJchemReg
			%>
			</select>	
			<label for="salt_<% =numSalts %>_multiplicity">Multiplicity</label>
			<input type="text" name="salt_<% =numSalts %>_multiplicity" id="salt_<% =numSalts %>_multiplicity" class="multiplicVal" value= "<%=saltRec("multiplicity")%>" style="width: 80px">
			<input  type="checkbox" name="salt_<% =numSalts %>_deleteBtn" id="salt_<% =numSalts %>_deleteBtn" value = "delete">Delete<br>
			</div>
			</div>
		 

	<% 
		saltRec.movenext
	Loop
	saltRec.close
	Set saltRec = nothing 
	existSaltNum = numSalts 
	 'this value should not be displayed, it is the number of salts before editing %>
	<input type="text" name="existSaltNum" value= <% =numSalts %> style="display:none">

	<%If wasEmpty then%>
		<div class="item" style="width:430px;">
			<div class="inline">
				<span class="regFieldData">No Salts</span>
			</div>
		</div>
	<%End if%>
	</div>
	<%End if%>
</div>

<div class="item" style="border-top: 1px solid #AFAFAF;-webkit-border-radius: 10px 10px 0 0;border-radius: 10px 10px 0 0;">
	<span class="regFieldName">Registration Source:</span>
	<span class="regFieldData" id="regSource_view"><%=source%></span>
	<span class="regFieldDataEdit" style="display:none;font-size: 15px;padding: 10px;max-width: 587px;word-wrap: break-word;margin-left: 0;padding-left: 2px;"><%=source%></span>
</div>
<%If hasStructure then%>
<%
getStereo = False
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT actualField, dropDownId FROM customFields WHERE formName='Stereochemistry'"
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	getStereo = True
	stereoField = rec("actualField")
	dropDownId = rec("dropDownId")
End If
rec.close
Set rec = Nothing
If isGroup Then
	getStereo = False
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT actualField FROM groupCustomFieldFields WHERE actualField="&SQLClean(stereoField,"T","S")&" AND groupId="&SQLClean(groupId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		getStereo = true
	End If
	rec.close
	Set rec = nothing
End if
If getStereo Then
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT parent_cd_id from "&regMoleculesTable&" WHERE cd_id="&SQLClean(parentCdId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	realParentCdId = rec("parent_cd_id")
	rec.close
	Set rec = nothing
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT "&stereoField&" FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(realParentCdId,"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		stereoValue = rec(stereoField)
		If IsNull(stereoValue) Then
			stereoValue = ""
		End if
		If CStr(stereoValue) = "-1" Then
			stereoValue = ""
		End If
		%>
			<div class="item">
				<span class="regFieldName">Stereochemistry:</span>
				<span class="regFieldData" id="userModified_view"><%=stereoValue%></span>
			</div>
		<%
	End If
	rec.close
	Set rec= nothing
End if
%>
<%If Not polymer then%>
	<%
	hideChemicalNameFieldInReg = checkBoolSettingForCompany("hideChemicalNameFieldInReg", session("companyId"))
	if not hideChemicalNameFieldInReg then
	%>
		<div class="item" >
			<span class="regFieldName">Chemical Name:</span>
			<span class="regFieldData" id="chemicalName_view"><%=chemicalName%></span>
			<input class="regFieldDataEdit" name="chemicalName" id="chemicalName" type="text" value="<%=chemicalName%>" style="display:none;">
		</div>
	<%End if%>
<%End if%>
<div class="item" >
	<span class="regFieldName">Formula:</span>
	<span class="regFieldData" id="molecularFormula_view"><%=molecularFormula%></span>
	<input class="regFieldDataEdit" name="molecularFormula" id="molecularFormula" type="text" value="<%=molecularFormula%>" style="display:none;">
</div>
<%
thisCdId = parentCdId
If dontUseParentCdId Then
	thisCdId = theCdId
End if
molWeightWithSalts = molWeight
smilesWithSalts = smiles
Set saltRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT cd_molweight,multiplicity,cd_smiles FROM "&regSaltsView&" WHERE molId="&SQLClean(thisCdId,"N","S")
saltRec.open strQuery,jchemRegConn,3,3
Do While Not saltRec.eof
	molWeightWithSalts = molWeightWithSalts + (saltRec("CD_MOLWEIGHT")*saltRec("MULTIPLICITY"))
	For i = 1 To saltRec("MULTIPLICITY")
		If saltRec("cd_smiles") <> "" Then
			smilesWithSalts = smilesWithSalts & "." &Split(saltRec("cd_smiles")," ")(0)
		End If
	Next
	saltRec.movenext
Loop
saltRec.close
Set saltRec = nothing
molWeightWithSalts = Round(molWeightWithSalts,2)
%>
<%If Not polymer then%>
<div class="item">
	<span class="regFieldName">SMILES:</span>
	<span class="regFieldData" id="smiles_view"><%=smiles%></span>
	<input class="regFieldDataEdit" name="smiles" id="smiles" type="text" value="<%=smiles%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">SMILES (w/salts):</span>
	<span class="regFieldData" id="smilesWithSalts_view"><%=smilesWithSalts%></span>
	<input class="regFieldDataEdit" name="smilesWithSalts" id="smilesWithSalts" type="text" value="<%=smilesWithSalts%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">Molecular Weight:</span>
	<span class="regFieldData" id="molecularWeight_view"><%=molWeight%></span>
	<input class="regFieldDataEdit" name="molecularWeight" id="molecularWeight" type="text" value="<%=molWeight%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">Molecular Weight (w/salts):</span>
	<span class="regFieldData" id="molecularWeightWithSalts_view"><%=molWeightWithSalts%></span>
	<input class="regFieldDataEdit" name="molecularWeightWithSalts" id="molecularWeightWithSalts" type="text" value="<%=molWeightWithSalts%>" style="display:none;">
</div>
<div class="item">
	<span class="regFieldName">Exact Mass:</span>
	<span class="regFieldData" id="exactMass_view"><%=exactMass%></span>
	<input class="regFieldDataEdit" name="exactMass" id="exactMass" type="text" value="<%=exactMass%>" style="display:none;">
</div>
<%End if%>
<%End if%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
If isGroup Then
	strQuery = "SELECT * FROM groupCustomFieldFields WHERE showBatch=1 and groupId="&SQLClean(groupId,"N","S")
else
	strQuery = "SELECT * FROM customFields WHERE showBatch=1"
End If
If hasRegSorting Then
	strQuery = strQuery & " ORDER BY sortOrder ASC, id ASC"
Else
	strQuery = strQuery & " ORDER BY id ASC"
End if
rec.open strQuery,jChemRegConn,3,3
Do While Not rec.eof
	lastIndex = lastIndex + 1
	theValue = regJson.Get(fieldsArr.Get(lastIndex))
	originalValue = theValue
	theValue = Replace(theValue,Chr(10),"<br/>")
	theValue = Replace(theValue,Chr(13),"<br/>")
	specialValue = theValue
	If rec("dataType") = "long_text" And rec("isLink") = 1 Then
		specialValue = ""
		regIds = Split(theValue,"<br/>")
		For i = 0 To UBound(regIds)
			If regIds(i) <> "" then
				specialValue = specialValue &"<a href='showRegItem.asp?regNumber="&regIds(i)&"'>"&regIds(i)&"</a>"
			End If
			If i<UBound(regIds) Then
				specialValue = specialValue & "<br/>"
			End if
		Next
	End If
	
    hasLongTextIdFieldsReg = checkBoolSettingForCompany("canUseLongTextFieldsAsIdForReg", session("companyId"))
	If hasLongTextIdFieldsReg And rec("isIdentity") = 1 And rec("dataType") = "long_text" Then
		theValue = Replace(theValue,",","</br>")
	End if
	theValue = Replace(theValue,"###","<br/>")
%>
	<%If CStr(rec("showBatch"))  = "1" And CStr(rec("showBatchInput"))="0" then%>
		<div class="item">
			<span class="regFieldName"><%=rec("displayName")%></span>
			<%
			theVal = ""
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT "&rec("actualfield")&" FROM "&regMoleculesTable&" WHERE cd_id="&SQLClean(theParentCdId,"N","S")
			rec2.open strQuery,jchemRegConn,0,-1
			If Not rec2.eof Then
				If Not IsNull(rec2(CStr(rec("actualfield")))) then
					theVal = rec2(CStr(rec("actualfield")))
				End if
			End If
			rec2.close
			Set rec2 = nothing
			%>
			<%If rec("dataType")="file" then%>
				<input type="hidden" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=theValue%>">
				<span id="<%=rec("formName")%>_fn">
				<%
				id = theVal
				If id<>"" Then
					Set rec3 = server.CreateObject("ADODB.RecordSet") 
					strQuery = "SELECT * FROM fileAttachments WHERE id="&SQLClean(id,"N","S")
					rec3.open strQuery,jchemRegConn,3,3
					If Not rec3.eof Then
						filename = rec3("filename")
						%>
						<%=filename%>
						<%
					End if
					rec3.close
					Set rec3 = nothing
				End if
				%>
				</span>
				<div class="downloadButtonHolder"><a href="<%If id="" then%>javascript:void(0);<%else%>getSourceFile.asp?id=<%=id%><%End if%>" id="<%=rec("formName")%>_download_button" class="littleButton" style="float:none;width:80px;display:inline;margin-left:10px;<%If id="" then%>display:none;<%End if%>">Download</a></div>
				<div id="<%=rec("formName")%>_img_holder" style="margin-left:15px;<%If id="" Or Not canDisplayInBrowser(filename) then%>display:none;<%End if%>">
				<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='block';document.getElementById('<%=rec("formName")%>_img_show').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='inline';" <%If id="" then%>style="display:none;"<%End if%> id="<%=rec("formName")%>_img_show">Show Image</a>
				<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='none';document.getElementById('<%=rec("formName")%>_img_show').style.display='inline';" id="<%=rec("formName")%>_img_hide" <%If id<>"" then%>style="display:none;"<%End if%>>Hide Image</a>
				<img src="<%If id="" then%>javascript:false<%else%>getImage.asp?id=<%=id%><%End if%>" style="<%If inframe then%>width:200px;<%else%>width:800px;<%End if%>display:none;" id="<%=rec("formName")%>_img"/>
				</div>
			<%elseIf rec("dataType")="drop_down" then%>
				<%If cStr(theVal) = "-1" Then%>
					<span class="regFieldData"></span>	
				<%else%>
					<span class="regFieldData" id="userModified_view"><%=theVal%></span>
				<%end if%>
				<%If CInt(rec("dropDownId")) <> -99 then%>
					<input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="hidden" value="<%=theVal%>" style="display:none;" />
				<%End if%>
			<%else%>
				<span class="regFieldData" id="userModified_view"><%=theVal%></span>
				<span class="regFieldDataEdit" style="display:none;font-size: 15px;padding: 10px;max-width: 587px;word-wrap: break-word;margin-left: 0;padding-left: 2px;"><%=theVal%></span>
			<%End if%>
		</div>
	<%else%>
		<div class="item">
			<span class="regFieldName"><%=rec("displayName")%></span>
			<%If rec("dataType")="drop_down" And theValue = "-1" Then%>
				<span class="regFieldData"></span>	
			<%else%>
				<%If rec("isLink") = 1 And  rec("dataType") <> "long_text" then%>
					<%
					scriptName = "showReg.asp"
					If InStr(theValue, regBatchNumberDelimiter) <> 0 Then

						batchValueParts = Split(theValue,regBatchNumberDelimiter)
						highestIndex = UBound(batchValueParts)						

						' if the users created a groupPrefix for a group containing another delimiter,
						' it would disrupt how we determine which link to show...so, we compensate here
						regNumberDelimiter = getCompanySpecificSingleAppConfigSetting("regIdDelimiter", session("companyId"))
						If ((Len(groupPrefix) > 0) And (InStr(groupPrefix, regBatchNumberDelimiter) Or InStr(groupPrefix, regNumberDelimiter))) Then
							numberOfBatchNumberDelimiters = len(groupPrefix) - len(replace(groupPrefix, regBatchNumberDelimiter, ""))							
							numberOfRegNumberDelimiters = 0

							If (regBatchNumberDelimiter <> regNumberDelimiter) Then
								numberOfRegNumberDelimiters = len(groupPrefix) - len(replace(groupPrefix, regNumberDelimiter, ""))
							End If

							highestIndex = highestIndex - (numberOfBatchNumberDelimiters + numberOfRegNumberDelimiters)
						End If						

						If (regBatchNumberDelimiter <> regNumberDelimiter And highestIndex = 1) Or (regBatchNumberDelimiter = regNumberDelimiter And highestIndex = 2) Then
							scriptName = "showBatch.asp"
						End If
					End If
					%>
					<span class="regFieldData"><a href="<%=scriptName%>?regNumber=<%=theValue%>"><%=theValue%></a></span>
				<%else%>
					<%If rec("dataType") = "long_text" then%>
						<div class="regFieldData" id="<%=rec("formName")%>_view"><%=specialValue%></div>
					<%elseif rec("dataType") = "read_only" then%>
							<span class="regFieldData" id="<%=rec("formName")%>_view"><%=theValue%></span>
							<span class="regFieldDataEdit" style="display: none; font-size: 15px; padding: 10px 10px 10px 2px; max-width: 587px; overflow-wrap: break-word; margin-left: 0px;"><%=theValue%></span>
					<%else%>
						<%If rec("dataType") <> "file" then%>
							<span class="regFieldData" id="<%=rec("formName")%>_view"><%=theValue%></span>
						<%End if%>
					<%End if%>
				<%End if%>
			<%End if%>
			<%If rec("dataType")="float" Or rec("dataType")="int" Or rec("dataType")="text" then%>		
				<input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="text" value="<%=theValue%>" style="display:none;">
			<%End if%>
			<%If rec("dataType")="multi_float" Or rec("dataType")="multi_int" Or rec("dataType")="multi_text" then%>		
				<div class="multiHolder regFieldDataEdit" id="<%=rec("formName")%>_holder" style="display:none;">
					<input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="hidden" value="<%=originalValue%>" style="display:none;">
				</div>
			<%End if%>
			<%If rec("dataType")="date" then%>		
				<input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="text" value="<%=theValue%>" style="display:none;">
				<script type="text/javascript">
				  Calendar.setup(
					{
					  inputField  : "<%=rec("formName")%>",         // ID of the input field
					  ifFormat    : "%m/%d/%Y %l:%M:%S %p",    // the date format
					  showsTime   : true,
					  timeFormat  : "12",
					  electric    : false
					}
				  );
				</script>
			<%End if%>
			<%If rec("dataType")="long_text" then%>
				<textarea class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" style="display:none;"><%=Replace(theValue,"<br/>",vbcrlf)%></textarea>
			<%End if%>
			<%If rec("dataType")="file" then%>
				<input type="hidden" name="<%=rec("formName")%>" id="<%=rec("formName")%>" value="<%=theValue%>" class="ThisIsATest">
				<span id="<%=rec("formName")%>_fn">
				<%
				id = theValue
				If id<>"" Then
					Set rec3 = server.CreateObject("ADODB.RecordSet") 
					strQuery = "SELECT * FROM fileAttachments WHERE id="&SQLClean(id,"N","S")
					rec3.open strQuery,jchemRegConn,3,3
					If Not rec3.eof Then
						filename = rec3("filename")
						%>
						<%=filename%>
						<%
					End if
					rec3.close
					Set rec3 = nothing
				End if
				%>
				</span>
				<div class="downloadButtonHolder"><a href="<%If id="" then%>javascript:void(0);<%else%>getSourceFile.asp?id=<%=id%><%End if%>" id="<%=rec("formName")%>_download_button" class="littleButton" style="float:none;width:80px;display:inline;margin-left:10px;<%If id="" then%>display:none;<%End if%>">Download</a></div>
				<div id="<%=rec("formName")%>_img_holder" style="margin-left:15px;<%If id="" Or Not canDisplayInBrowser(filename) then%>display:none;<%End if%>">
				
				<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='block';document.getElementById('<%=rec("formName")%>_img_show').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='inline';" <%If id="" then%>style="display:none;"<%End if%> id="<%=rec("formName")%>_img_show">Show Image</a>

				<a href="javascript:void(0);" onclick="document.getElementById('<%=rec("formName")%>_img').style.display='none';document.getElementById('<%=rec("formName")%>_img_hide').style.display='none';document.getElementById('<%=rec("formName")%>_img_show').style.display='inline';" id="<%=rec("formName")%>_img_hide" <%If id<>"" then%>style="display:none;"<%End if%>>Hide Image</a>
				
				<img src="<%If id="" then%>javascript:false<%else%>getImage.asp?id=<%=id%><%End if%>" style="<%If inframe then%>width:200px;<%else%>width:800px;<%End if%>display:none;" id="<%=rec("formName")%>_img"/>
				</div>
				<div style="margin-left:15px">
				<a href="javascript:void(0);" onclick="if (confirm('Are you sure you want to remove the File?')) {document.getElementById('<%=rec("formName")%>').value = '';document.getElementById('<%=rec("formName")%>_img_holder').style.display='none';document.getElementById('<%=rec("formName")%>_fn').style.display='none';document.getElementById('<%=rec("formName")%>_download_button').style.display='none';}" class="regFieldDataEdit" id="<%=rec("formName")%>_remove_img" <%If not isNull(theValue) then%>style="display:none;"<%End if%>>Remove File</a>
				</div>
				<iframe id="<%=rec("formName")%>_frame" name="<%=rec("formName")%>_frame" style="border:none;height:35px;width:300px;margin-left:15px;display:none;" src="upload-file_frame.asp?formName=<%=rec("formName")%>" scrolling="no" class="regFieldDataEdit"></iframe>
			<%End if%>
			<%If rec("dataType")="drop_down" then%>
				<%If CInt(rec("dropDownId")) <> -99 then%>
					<select class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" style="display:none;">
					<option value="-1">--SELECT--</option>
					<%
					Set rec2 = server.CreateObject("ADODB.recordSet")
					strQuery = "SELECT * FROM regDropDownOptions WHERE parentId="&SQLClean(rec("dropDownId"),"N","S")&" ORDER BY value"
					rec2.open strQuery,jchemRegConn,3,3
					Do While Not rec2.eof
						%>
						<option value="<%=rec2("value")%>" <%If Trim(theValue)=Trim(rec2("value")) then%>SELECTED<%End if%>><%=rec2("value")%></option>
						<%
						rec2.movenext
					Loop
					rec2.close
					Set rec2 = nothing
					%>
					</select>
				<%else%>
					<%
						Set rec2 = Server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT * FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id in("&getUsersICanSee()&")"
						rec2.open strQuery,conn,3,3
						foundScientist = False
						Do While Not rec2.eof
							If theValue =rec2("firstName")&" " &rec2("lastName")  Or theValue =rec2("lastName")&", " &rec2("firstName") Then
								foundScientist = True
							End if
							rec2.movenext
						Loop
						rec2.close
						If Not foundScientist And theValue <> "" Then
							%><input class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" type="text" value="<%=theValue%>" style="display:none;"><%
						Else
							%>
							<select class="regFieldDataEdit" name="<%=rec("formName")%>" id="<%=rec("formName")%>" style="display:none;">
							<option value="-1">--SELECT--</option>
							<%
							strQuery = "SELECT * FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id in("&getUsersICanSee()&")"
							rec2.open strQuery,conn,3,3
							Do While Not rec2.eof
								%>
									<option value="<%=rec2("firstName")&" "&rec2("lastName")%>" <%If theValue =rec2("firstName")&" " &rec2("lastName")  Or theValue =rec2("lastName")&", " &rec2("firstName") then%> SELECTED<%End if%>><%=rec2("firstName")%>&nbsp;<%=rec2("lastName")%></option>
								<%
								rec2.movenext
							loop
							%>
							</select>
							<%
						End if
					%>
				<%End if%>
			<%End if%>
		</div>
	<%End if%>
<%
	rec.movenext
Loop
rec.close
Set rec = nothing
%>
<%If (session("regRegistrar") And Not session("regRegistrarRestricted")) Or session("canEditReg") then%>
<div>
<input type="button" value="EDIT BATCH" onclick="toggleEdit()" id="editToggleButton">
<input type="submit" value="SAVE CHANGES" name="editSubmit" id="editSubmit" style="display:none;">
</div>
<%End if%>
</form>

<%If canDeleteStructureReg then%>
	<form action="showBatch.asp?regNumber=<%=request.querystring("regNumber")%>" method="POST" onsubmit="return confirm('Are you sure that you wish to delete this batch?');" style="margin:0px 0px 0px 0px;left:50px;bottom:0px;">
		<input type="hidden" name="deleteStructureCdId" id="deleteStructureCdId" value="<%=theCdid%>">
		<input type="hidden" name="deleteStructureSubmitted" id="deleteStructureSubmitted" value="submitted2">
		<input type="submit" value="DELETE BATCH" id="regDeleteButton">
	</form>
<%End if%>

</div>

<%If (perm="" Or perm="0") And statusId <> "2" And session("regRegistrar") And Not session("regRegistrarRestricted") then %>
<form method="POST" style="padding-top:25px;" action="showBatch.asp?regNumber=<%=request.querystring("regNumber")%>">
<input type="hidden" name="cdId" value="<%=parentCdId%>">
<input type="submit" name="approveSubmit" value="APPROVE FROM QUEUE">
<input type="submit" name="deleteSubmit" value="REJECT FROM QUEUE" onclick="return confirm('Are you sure you wish to delete this batch?')">
</form>
<%End if%>

</div>
<%
'412015
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM experimentRegLinksView WHERE displayRegNumber="&SQLClean(wholeRegNumber,"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
rec.open strQuery,conn,0,-1
%>

<%If (Not IsNull(experimentId) And experimentId <> "") Or Not rec.eof then%>
  <table cellpadding="0" cellspacing="0" style="width:100%;">
	<tr>
		<td align="left" style="padding-bottom:0!important;" valign="top" colspan="2">
			<div class="tabs"><h2>ELN Links</h2></div>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<table class="caseTable" cellpadding="0" cellspacing="0" style="width:100%;">
				<tr>
					<td class="caseInnerTitle" valign="top" id="inventoryLinksTD">
					<%If (Not IsNull(experimentId) And experimentId <> "") then%>
						<%
							prefix = GetPrefix(experimentType)
							expPage = GetExperimentPage(prefix)
						%>
						<a href="<%=mainAppPath%>/<%=expPage%>?id=<%=experimentId%>" target="new"><%=experimentName%></a>
						<%
						Set rec2 = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT * FROM notebookIndexView WHERE details is not null and details <>'' and typeId="&SQLClean(experimentType,"N","S") & " and experimentId="&SQLClean(experimentId,"N","S")
						rec2.open strQuery,conn,0,-1
						If Not rec2.eof Then
							response.write("<p  class='linkDescription'>"&rec2("details")&"</p>")
						End if
						rec2.close
						Set rec2=nothing
						%>
						<%If Not rec.eof then%>
							<br/>
						<%End if%>
					<%End if%>
					<%If Not rec.eof then%>
						<%Do While Not rec.eof
							If Not (CStr(experimentId) = CStr(rec("experimentId")) And CStr(experimentType) = CStr(rec("experimentType"))) then%>
								
								<%prefix = GetPrefix(rec("experimentType"))
								expPage = GetExperimentPage(prefix)%>

								<a href="<%=mainAppPath%>/<%=expPage%>?id=<%=rec("experimentId")%>" target="new"><%=rec("name")%></a><br/>
								<%If Not IsNull(rec("details")) then%>
									<p class="linkDescription"><%=rec("details")%></p>
								<%End if%>
							<%End if%>
							<%rec.movenext%>	
						<%loop%>
					<%End if%>

					</td>
				</tr>
			</table>
		</td>
	</tr>
	</table>
<%End if%>
<%''/412015%>

<%
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "select cd_id,reg_id from "&regMoleculesTable&" WHERE cd_id="&SQLClean(theParentCdId,"N","S")&" AND parent_cd_id<>0"
rec.open strQuery,jchemRegConn,3,3
If rec.eof then
%>
<br/>
<a href="showReg.asp?regNumber=<%=left(request.querystring("regNumber"),InstrRev(request.querystring("regNumber"),regBatchNumberDelimiter)-1)%>" class="parentLink">Back to Parent</a>
<%else%>
<a href="showBatch.asp?regNumber=<%=rec("reg_id")%>" class="parentLink">Back to Parent</a>
<%End if%>

<script type="text/javascript">
//function loadInvLinks(){
//	$.get("getInventoryLinks.asp?cdId=<%=theCdId%>&random="+Math.random())
//		.done(function(data){
//			if(data!=""){
//				document.getElementById("inventoryLinksDiv").style.display = "block";
//				document.getElementById("inventoryLinksTable").innerHTML = data;
//			}
//		})
//}
//$(document).ready(loadInvLinks)

<% If IsNull(numSalts)  Or  IsEmpty(numSalts) Then 
       numSalts = 0
    End If %>

numSalts = <%= numSalts %>;
existSaltNum = numSalts;




function addNewSalts()
{

		 if (numSalts != 0)
        {
		var newHTML = getFile("getNewSalt.asp?saltNumber="+(numSalts+1)+"&random="+Math.random())
		newDiv = document.createElement("div")
		newDiv.setAttribute('id',"salt_"+(numSalts+1)+"_container")
		newDiv.innerHTML = newHTML;
		document.getElementById("salt_"+numSalts+"_container").parentNode.insertBefore(newDiv,document.getElementById("salt_"+numSalts+"_container").nextSibling);
        document.getElementById("salt_"+(numSalts+1)+"_container").className += ' saltItemContainer';
		numSalts++;
	    }
	    else
	    {
	    numSalts = 1;
	    var newHTML = getFile("getNewSalt.asp?saltNumber="+numSalts+"&random="+Math.random())
		newDiv = document.createElement("div")
		newDiv.setAttribute('id',"salt_"+numSalts+"_container")
		newDiv.innerHTML = newHTML;
		document.getElementById("saltsContainer").append(newDiv);
        document.getElementById("salt_"+numSalts+"_container").className += ' saltItemContainer';
	    }
}

function toggleEdit()
{

		 
		spans = document.getElementsByClassName("regFieldData")
		boxes = document.getElementsByClassName("regFieldDataEdit")
		var spanExcludes = ["regId_view", "userCreated_view", "dateCreated_view", "userLastModified_view", "dateModified_view"];

		if (boxes[0].style.display == "none")
		{
			// show edit dashboard
		    for(i =1;i<existSaltNum+1;i++)
           {
		     	document.getElementById("salt_"+i+"_display").style.display ="none"
		     	document.getElementById("salt_"+i+"_edit").style.display ="inline"
		     	
		    }
			for (i=0;i<spans.length ;i++ )
			{
				if (!spanExcludes.includes(spans[i].id)){
					spans[i].style.display = "none"
				}
			}
			for (i=0;i<boxes.length ;i++ )
			{
				if(boxes[i].tagName=="SPAN"){
					boxes[i].style.display = "inline-block"
				}else{
					boxes[i].style.display = "inline"
				}
			}
		    
            if (document.getElementById("addSaltsBtn") != null){
		    	document.getElementById("addSaltsBtn").style.display = "inline"
		    }
			document.getElementById("editSubmit").style.display = "inline"
			document.getElementById("editToggleButton").value = "CANCEL"
		}

		else
		{

			// delete the extra divs of salt when people click cancel
             for(i = existSaltNum+1;i<numSalts+1;i++)
             {
             	document.getElementById("salt_"+i+"_container").remove();

             }
              // show display
			 for(i =1;i<existSaltNum+1;i++)
            {
		     	document.getElementById("salt_"+i+"_display").style.display ="inline"
		     	document.getElementById("salt_"+i+"_edit").style.display ="none"
		     	
		    }
			for (i=0;i<spans.length ;i++ )
			{
				spans[i].style.display = "inline-block"
			}
			for (i=0;i<boxes.length ;i++ )
			{
				boxes[i].style.display = "none"
			}
			numSalts = existSaltNum
            if (document.getElementById("addSaltsBtn") != null){
		    	document.getElementById("addSaltsBtn").style.display = "none"
		    }
			document.getElementById("editSubmit").style.display = "none"
			document.getElementById("editToggleButton").value = "EDIT"
			
		}
}








function getRegInventoryLinks(){
	$.get("getInventoryLinksFromInventory.asp?regNumber=<%=request.querystring("regNumber")%>&random="+Math.random())
		.done(function(data){
			if(data!=""){
				$("#inventoryLinksTable").empty();
				theLinks = JSON.parse(data);
				table = document.createElement("table");
				table.style.width = "40%";
				table.className = "experimentsTable";
				tbody = document.createElement("tbody");
				tr = document.createElement("tr");
				th = document.createElement("th");
				th.appendChild(document.createTextNode("Name"));
				tr.appendChild(th)
				th = document.createElement("th");
				th.appendChild(document.createTextNode("Barcode"));
				tr.appendChild(th)
				th = document.createElement("th");
				th.appendChild(document.createTextNode("Amount"));
				tr.appendChild(th);
				tbody.appendChild(tr);
				if(theLinks.length==0){
					tr = document.createElement("tr");
					td = document.createElement("td");
					td.setAttribute("colspan","3");
					td.appendChild(document.createTextNode("No Links Found"));
					tr.appendChild(td);
					tbody.appendChild(tr);
				}
				for (var i=0;i<theLinks.length;i++){
					tr = document.createElement("tr");
					td = document.createElement("td");
					td.appendChild(document.createTextNode(theLinks[i]["registrationId"]));
					tr.appendChild(td);
					td = document.createElement("td");
					a = document.createElement("a")
					a.href = "<%=mainAppPath%>/inventory2/index.asp?id="+theLinks[i]["id"];
					a.appendChild(document.createTextNode(theLinks[i]["barcode"]));
					td.appendChild(a);
					tr.appendChild(td);
					td = document.createElement("td");
					td.appendChild(document.createTextNode(theLinks[i]["amount"]));
					tr.appendChild(td);
					tbody.appendChild(tr);
				}
				table.appendChild(tbody);
				document.getElementById("inventoryLinksTable").appendChild(table);
				document.getElementById("inventoryLinksDiv").style.display = "block";
			}
		})
}
</script>

<iframe src="javascript:void(0);" width="860" height="700" id="batchTableFrame" style="border:none;<%if Not allowBatchesOfBatches Then%>display:none;<%End if%>" border="0"></iframe>
</div>

<%If regHasTemplate then%>
<%
extra = "&addBatch=1"
%>
<script type="text/javascript">
$(document).ready(function(){
	$.get("getTemplate.asp?groupId=<%=groupId%><%=extra%>&random="+Math.random())
		.done(function(data){
			div = document.createElement("div");
			div.innerHTML = data;
			div.setAttribute("id","regTemplate")
			regForm = document.getElementById("regForm");
			theForm = document.createElement("form");
			theForm.setAttribute("method",regForm.getAttribute("method"))
			theForm.setAttribute("action",regForm.getAttribute("action"))
			theForm.appendChild(div);
			document.getElementById('regTemplateHolder').appendChild(theForm);
			$("#regTemplate [formName]").each(function(i,el){
				targetEl = document.getElementById(el.getAttribute("formname")+"_view");
				if(targetEl){
					$(el).append(targetEl);
				}
				targetEl = document.getElementById(el.getAttribute("formname"));
				if(targetEl){
					$(el).append(targetEl);
				}
				//targetEl = $("#"+fd.fid+" > [formName='"+el.getAttribute("formName")+"_error']");
				//if(targetEl){
				//	$(el).append(targetEl);
				//}
			});
			delayedRunJS(data);

          $(".item").css('margin-top',0);

			<%if allowBatchesOfBatches Then%>
			window.setTimeout(function(){
			try{
				a = tableFieldsToShow;
			}catch(err){
				tableFieldsToShow = "molecule,just_batch,cd_molweight,user_name,cd_timestamp,source";
				tableLinkField = "just_batch";
			}
			document.getElementById("batchTableFrame").src="batchTable.asp?cdId=<%=theCdId%>&regNumber=<%=theRegId%>&fieldsToShow="+tableFieldsToShow+"&tableLinkField="+tableLinkField;},500)
			<%end if%>
		});
});
</script>
<%else%>
<script type="text/javascript">
	document.getElementById("batchTableFrame").src="batchTable.asp?cdId=<%=theCdId%>&regNumber=<%=theRegId%>&groupId=<%=groupId%>"
</script>
<%End if%>
<script type="text/javascript" src="js/multiText.js?<%=jsRev%>"></script>
<script type="text/javascript">
$(document).ready(function(){
	makeMultis();

});
</script>
<%
thisMol = CX_cdIdSearch(jChemRegDB,regMoleculesTable,SQLClean(theCdId,"N","S"),"mol:V3")
Set thisMolObj = JSON.parse(thisMol)
If IsObject(thisMolObj) Then
	If thisMolObj.Exists("structureData") Then
		Set structureData = thisMolObj.Get("structureData")
		If IsObject(structureData) And structureData.Exists("structure") Then
			molDataForAdd = structureData.Get("structure")
		End If
	End If
End If
%>
<input type="hidden" id="molDataForAdd" value="<%=molDataForAdd%>">
<input type="hidden" id="cdIdForAdd" value="<%=theCdid%>">


	<!-- #include file="../_inclds/footer-tool.asp"-->