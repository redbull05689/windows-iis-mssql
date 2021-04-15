<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
regTextFieldLimit = getCompanySpecificSingleAppConfigSetting("numberOfRegCustomFields", session("companyId"))
regLongTextFieldLimit = getCompanySpecificSingleAppConfigSetting("numberOfRegLongTextFields", session("companyId"))
globalSupportEmailAddress = getCompanySpecificSingleAppConfigSetting("globalSupportEmailAddress", session("companyId"))

sectionId = "reg"
subSectionId = "custom-fields"
if Not session("regRegistrar") Or session("regRegistrarRestricted") Then
	response.redirect("logout.asp")
End If
%>

<%
groupId = request.querystring("groupId")
If isInteger(groupId) Then 
	'5115
	If request.querystring("set")="1" then
		isGroup = True
		isSet = True
		subSectionId = "combo-custom-fields"
		redirectPage = "comboCustomFields.asp"
		fieldsTable = "comboCustomFields"
		fieldFieldsTable = "comboCustomFieldFields"
	else
		isGroup = True
		subSectionId = "group-custom-fields"
		redirectPage = "groupCustomFields.asp"
		fieldsTable = "groupCustomFields"
		fieldFieldsTable = "groupCustomFieldFields"
	End if
	'/5115
Else
	isGroup = False
End if

If request.Form("customFieldsSubmit") <> "" Then
	Call getconnectedJchemReg
	numFields = request.Form("cfNumFields")
	nameError = False
	typeError = False
	If isGroup Then
		If request.Form("hasStructure") = "on" Then
			hs = 1
		Else
			hs = 0
		End If
		If request.Form("useSalts") = "on" Then
			us = 1
		Else
			us = 0
		End If
		If request.Form("allowBatchesOfBatches") = "on" Then
			bb = 1
		Else
			bb = 0
		End If
		If request.Form("allowBatches") = "on" Then
			ab = 1
		Else
			ab = 0
		End If
		If request.Form("restrictAccess") = "on" Then
			ra = 1
		Else
			ra = 0
		End If
		'5115 fields table var

		
		strQuery = "UPDATE "&fieldsTable&" SET " &_
		"groupPrefix="&SQLClean(request.Form("groupPrefix"),"T","S")&"," &_ 
		"name="&SQLClean(request.Form("groupName"),"T","S")&"," &_
		"hasStructure="&SQLClean(hs,"N","S")&"," &_
		"useSalts="&SQLClean(us,"N","S")&"," &_
		"allowBatchesOfBatches="&SQLClean(bb,"N","S")&","&_
		"restrictAccess="&SQLClean(ra,"N","S") &"," &_
		"restrictGroupIds="&SQLClean(request.Form("groupIds"),"T","S") &"," &_
		"restrictUserIds="&SQLClean(request.Form("userIds"),"T","S") &"," &_
		"allowBatches="&SQLClean(ab,"N","S")&_
		" WHERE id="&SQLClean(groupId,"N","S")

		jchemRegConn.execute(strQuery)
		Set tRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT top 1 * FROM "&fieldsTable&" WHERE 1=1"
		'response.write(strQuery)
		'response.end
		tRec.open strQuery,jchemRegConn,3,3
		If Not tRec.eof Then
			If columnExists(tRec,"imageWidth") And columnExists(tRec,"imageHeight") Then
				strQuery = "UPDATE "&fieldsTable&" SET imageWidth="&SQLClean(request.Form("structureWidth"),"N","S")&",imageHeight="&SQLClean(request.Form("structureHeight"),"N","S")&" WHERE id="&SQLClean(groupId,"N","S")
				jchemRegConn.execute(strQuery)
			End If
		End if
		tRec.close
		Set tRec = nothing
	End if
	For i = 1 To numFields
		If isGroup Then
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM customFields WHERE id="&SQLClean(request.Form("cfId_"&i),"N","S")
			rec.open strQuery,jchemRegConn,3,3
			If Not rec.eof Then
				displayName = rec("displayName")
				dropDownId = rec("dropDownId")
				formName = rec("formName")
				dataType = rec("dataType")
				actualField = rec("actualField")
			End if
		else
			displayName = request.Form("cfDisplayName_"&i)
			dropDownId = request.Form("cfDropDownId_"&i)
			formName = Trim(displayName)

			Set re = new RegExp
			re.IgnoreCase = true
			re.Global = true
			re.Pattern = "[^A-Za-z0-9]"
			formName = re.Replace(formName,"_")
			set re = nothing

			dataType = request.Form("cfDataType_"&i)
			If dataType = "int" Or dataType = "float" Or dataType = "date" Or dataType = "text" Or dataType = "drop_down" Or dataType="file" Then
				dbPrefix = "vc"
				dbLimit = regTextFieldLimit
			End If
			If dataType = "long_text" Then
				dbPrefix = "t"
				dbLimit = regLongTextFieldLimit
			End if
			
			' This whole block is slow		
			foundSpace = False
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "select ISNULL(max(CAST(REPLACE(actualField, '" & dbPrefix & "_', '')as int)),0) from customFields where actualField like '" & dbPrefix & "_%'"
			rec.open strQuery,jchemRegConn,3,3
			If not rec.eof Then
				if rec(0) <= CInt(dbLimit) Then
					foundSpace = True
					dbNumber = rec(0) + 1
				End if
			End If
			rec.close
		
			Set rec = nothing
			
			
			If Not foundSpace Then
				formError = True
				If dbPrefix = "vc" then
					errorText = "You have exceeded the limit for the combination of data types int,float,date and text.  The current limit is "&regTextFieldLimit&".  Please email Arxspan Support at "&globalSupportEmailAddress&" for details."
				End If
				If dbPrefix = "t" then
					errorText = "You have exceeded the limit for the data type long text.  The current limit is "&regLongTextFieldLimit&".  Please email Arxspan Support at "&globalSupportEmailAddress&" for details."
				End if
			End if

			If Trim(displayName) = "" Then
				formError = True
				nameError = true
			End if
			If dataType = "" Or dataType = "-1" Then
				formError = True
				typeError = true
			End if
		End if

		If Not formError then
			If request.Form("cfReadOnly_"&i) <> "true" Then
				strQuery = ""
				If isGroup Then
					'5115 added fieldFieldsTable
					strQuery = strQuery & "INSERT INTO "&fieldFieldsTable&"(displayName,formName,dataType,actualField,dropDownId,groupId) output inserted.id as newId values("&_
							SQLClean(displayName,"T","S") & "," &_
							SQLClean(formName,"T","S") & "," &_
							SQLClean(dataType,"T","S") & "," &_
							SQLClean(actualField,"T","S") &"," &_
							SQLClean(dropDownId,"N","S")& "," &_
							SQLClean(groupId,"N","S")&")"				
				else
					strQuery = strQuery & "INSERT INTO customFields(displayName,formName,dataType,actualField,dropDownId) output inserted.id as newId values("&_
							SQLClean(displayName,"T","S") & "," &_
							SQLClean(formName,"T","S") & "," &_
							SQLClean(dataType,"T","S") & "," &_
							SQLClean(dbPrefix&"_"&dbNumber,"T","S") &"," &_
							SQLClean(dropDownId,"N","S")&")"
				End if
				Set rs = jchemRegConn.execute(strQuery)
				theId = CStr(rs("newId"))
			Else
				theId = request.Form("rowId_"&i)
			End If

			sb = request.Form("showBatch_"&i)
			rb = request.Form("requireBatch_"&i)
			sc = request.Form("showCompound_"&i)
			rc = request.Form("requireCompound_"&i)
			bi = request.Form("showBatchInput_"&i)
			ci = request.Form("showCompoundInput_"&i)
			eu = request.Form("enforceUnique_"&i)
			ii = request.Form("isIdentity_"&i)
			il = request.Form("isLink_"&i)
			If sb="on" Then
				sb=1
			Else
				sb=0
			End if
			If rb="on" Then
				rb=1
			Else
				rb=0
			End If
			If sc="on" Then
				sc=1
			Else
				sc=0
			End If
			If rc="on" Then
				rc=1
			Else
				rc=0
			End If
			If bi="on" Then
				bi=1
			Else
				bi=0
			End If
			If ci="on" Then
				ci=1
			Else
				ci=0
			End If
			If eu="on" Then
				eu=1
			Else
				eu=0
			End If
			If ii="on" Then
				ii=1
			Else
				ii=0
			End If
			If il="on" Then
				il=1
			Else
				il=0
			End If
			If isGroup Then
				'5115 added fields table var
				strQuery = "UPDATE "&fieldFieldsTable&" SET "&_
					"showBatch="&SQLClean(sb,"N","S") & "," &_
					"requireBatch="&SQLClean(rb,"N","S") & "," &_
					"showCompound="&SQLClean(sc,"N","S") & "," &_
					"requireCompound="&SQLClean(rc,"N","S") & "," &_
					"showBatchInput="&SQLClean(bi,"N","S") & "," &_
					"showCompoundInput="&SQLClean(ci,"N","S") & "," &_
					"enforceUnique="&SQLClean(eu,"N","S") & "," &_
					"isIdentity="&SQLClean(ii,"N","S") &"," &_
					"isLink="&SQLClean(il,"N","S") &"," &_
					"groupId="&SQLClean(groupId,"N","S")&" WHERE id="&SQLClean(theId,"N","S")
			else
				strQuery = "UPDATE customFields SET "&_
					"showBatch="&SQLClean(sb,"N","S") & "," &_
					"requireBatch="&SQLClean(rb,"N","S") & "," &_
					"showCompound="&SQLClean(sc,"N","S") & "," &_
					"requireCompound="&SQLClean(rc,"N","S") & "," &_
					"showBatchInput="&SQLClean(bi,"N","S") & "," &_
					"showCompoundInput="&SQLClean(ci,"N","S") & "," &_
					"isIdentity="&SQLClean(ii,"N","S") &"," &_
					"isLink="&SQLClean(il,"N","S") &"," &_
					"enforceUnique="&SQLClean(eu,"N","S") & " WHERE id="&SQLClean(theId,"N","S")
			End if
			jchemRegConn.execute(strQuery)

		End if

	Next
	Call disconnectJchemReg
	If Not formError Then
		If isGroup Then
			'5115 addded redirectPage var
			response.redirect(redirectPage)
		else
			response.redirect("customFields.asp")
		End if
	End If
	If errorText <> "" Then
		errorText = errorText & "<br/>"
	End if
	If nameError Then
		errorText = errorText & "One or more of your fields did not have a name and was not added.<br/>"
	End If
	If typeError Then
		errorText = errorText & "One or more of your fields did not have a type and was not added.<br/>"
	End if
End if
%>


<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include file="../_inclds/common/js/groupsJS.asp"-->
<!-- #include file="_inclds/popups.asp"-->
<%
call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
If isGroup Then
	'5115
	strQuery = "SELECT * FROM "&fieldFieldsTable&" WHERE groupId="&SQLClean(groupId,"N","S")
else
	strQuery = "SELECT * FROM customFields ORDER BY ID ASC"
End if

rec.open strQuery,jchemRegConn,3,3
numFields = rec.recordCount

%>
<script type="text/javascript">
numFields = <%=numFields%>;
//if (numFields == 0){numFields = 1;}
function validate()
{
	errors = ""
	returnVal = true
	numFields = document.getElementById("cfNumFields").value
	for(i=1;i<=numFields;i++)
	{
		<%if isGroup then%>
			if (document.getElementById('groupName')=='')
			{
				returnVal = false;
				errors+="Please enter a name for the group.\n"
			}
		<%end if%>
		//alert(i)
		el = document.getElementById('cfDropDownId_'+i)
		el2 = document.getElementById('cfDataType_'+i)
		//alert(el2.options[el2.selectedIndex].value + ' '+ el.options[el.selectedIndex].value)
		if(el)
		{
			if (el2.options[el2.selectedIndex].value == 'drop_down' && el.options[el.selectedIndex].value == '-1')
			{
				returnVal = false;
				errors+="Please select drop downs.\n"
			}
		}
		if (document.getElementById('cfDisplayName_'+i).value=="")
		{
			returnVal = false;
			errors+="Please enter names for all fields.\n"
		}
		el = document.getElementById('cfDataType_'+i) 
		if (el.options[el.selectedIndex].value=="-1")
		{
			returnVal = false;
			errors+="Please enter type for all fields.\n"
		}
	}
	if (!returnVal)
	{
		alert(errors)
	}
	return returnVal;
}
</script>
<%
rec.close
Set rec = nothing
call disconnectJchemReg
%>

<script type="text/javascript">
function insertAfter(parent, node, referenceNode) {
  parent.insertBefore(node, referenceNode.nextSibling);
}

function addNewField(id)
{
		<%'5115 aaded set%>	
		newHTML = getFile("getNewCustomFieldForm.asp?number="+(numFields+1)+"&random="+Math.random()+"&fieldId="+id+"&set=<%=request.querystring("set")%>")

		newDiv = document.createElement("div")
		newDiv.setAttribute('id',"field_"+(numFields+1)+"_container")
		newDiv.innerHTML = newHTML
		
		insertAfter(document.getElementById("field_"+numFields+"_container").parentNode,newDiv,document.getElementById("field_"+numFields+"_container"))
		numFields += 1;
		<%'5115 added not if set%>
		<%if not isSet then%>
		window.scrollTo(0, document.body.scrollHeight);
		<%end if%>
}
</script>

<div class="registrationPage">
<%If isGroup then%>
<%'5115%>
<%If isSet then%>
<h1>Custom Field Set</h1>
<%else%>
<h1>Custom Field Group</h1>
<%End if%>
<%'/5115%>
<%else%>
<h1><%=customFieldsLabel%></h1>
<%End if%>
<%If formError then%>
<div class="regErrorDiv">
	<%=errorText%>
</div>
<%End if%>
<%'5115 added set to form action%>
<form action="customFields.asp?groupId=<%=groupId%>&set=<%=request.querystring("set")%>" method="post" onsubmit="document.getElementById('cfNumFields').value=numFields != 0 ? numFields : 1;return validate();">
<%If isGroup Then
Call getconnectedJchemReg
hasStructure = false
'5115 added fields table var
Set rec2 = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM "&fieldsTable&" WHERE id="&SQLClean(groupId,"N","S")
rec2.open strQuery,jchemRegConn,3,3
If Not rec2.eof Then
	groupName = rec2("name")
	If Not IsNull(rec2("groupPrefix")) then
		groupPrefix = rec2("groupPrefix")
	End if
	If rec2("hasStructure") = 1 Then
		hasStructure = True
	End If
	If rec2("useSalts") = 1 Then
		useSalts = True
	End If
	If rec2("allowBatches") = 1 Then
		allowBatches = True
	End If
	If rec2("restrictAccess") = 1 Then
		restrictAccess = True
	End If
	If Not IsNull(rec2("restrictGroupIds")) Then
		groupIds = rec2("restrictGroupIds")
	End If
	If Not IsNull(rec2("restrictUserIds")) Then
		userIds = rec2("restrictUserIds")
	End if
	If rec2("allowBatchesOfBatches") = 1 Then
		allowBatchesOfBatches = True
	End If
	If columnExists(rec2,"imageWidth") And columnExists(rec2,"imageHeight") Then
		If IsNull(rec2("imageWidth")) then
			imageWidth = "300"
		Else
			If rec2("imageWidth") <> "" then
				imageWidth = rec2("imageWidth")
			Else
				imageWidth = "300"
			End if
		End if
		If IsNull(rec2("imageHeight")) then
			imageHeight = "300"
		Else
			If rec2("imageWidth") <> "" then
				imageHeight = rec2("imageHeight")
			Else
				imageHeight = "300"
			End if
		End if
		hasDims = True
	Else
		hasDims = False
	End if
End If
rec2.close
Set rec = nothing
Call disconnectJchemReg
%>
<label for="groupName">Display Name</label>
<input type="text" name="groupName" id="groupName" value="<%=groupName%>">
<br/>
<%'5115%>
<%If Not isSet then%>
<label for="groupPrefix">Group Prefix</label>
<input type="text" name="groupPrefix" id="groupPrefix" value="<%=groupPrefix%>">
<br/>
<label for="hasStructure">Has Structure</label>
<input type="checkbox" id="hasStructure" name="hasStructure" <%If hasStructure then%>checked<%End if%>>
<br/>
<label for="useSalts">Use Salts</label>
<input type="checkbox" id="useSalts" name="useSalts" <%If useSalts then%>checked<%End if%>>
<br/>
<label for="allowBatches">Allow Batches</label>
<input type="checkbox" id="allowBatches" name="allowBatches" <%If allowBatches then%>checked<%End if%>>
<br/>
<label for="allowBatchesOfBatches">Allow Batches Of Batches</label>
<input type="checkbox" id="allowBatchesOfBatches" name="allowBatchesOfBatches" <%If allowBatchesOfBatches then%>checked<%End if%>>
<br/>
<%If hasDims then%>
	<label for="groupPrefix">Structure Width</label>
	<input type="text" name="structureWidth" id="structureWidth" value="<%=imageWidth%>">
	<br/>
	<label for="groupPrefix">Structure Height</label>
	<input type="text" name="structureHeight" id="structureHeight" value="<%=imageHeight%>">
	<br/>
<%End if%>
<label for="allowBatches">Restrict Access</label>
<input type="checkbox" id="restrictAccess" name="restrictAccess" <%If restrictAccess then%>checked<%End if%>>
<br/>
<!-- #include file="../_inclds/common/html/groupsDiv.asp"-->
<a href="javascript:void(0)" onclick="populatePermsReg({'groupIds':[<%=groupIds%>],userIds:[<%=userIds%>]});showPopup('groupsDiv');toggleGroup(0);" class="groupSelectLink">Allowed Groups/Users</a>
<input type="hidden" id="groupIds" name="groupIds" value="<%=groupIds%>">
<input type="hidden" id="userIds" name="userIds" value="<%=userIds%>">
<input type="hidden" id="allUserIds" name="allUserIds" value="">
<input type="hidden" id="numUsers" name="numUsers" value="">
<input type="hidden" id="numGroups" name="numGroups" value="">
<%End if%>
<%'/5115%>
<br/>
<%End if%>
<%If isGroup then%>
<a href="javascript:void(0);" onClick="document.getElementById('addCustomFieldSelect').selectedIndex=0;showPopup('addCustomFieldDiv');return false;" class="greenNewButton" style="width:80px;" >ADD FIELD+</a>
<%else%>
<a href="javascript:void(0);" onClick="addNewField('');return false;" class="greenNewButton" style="width:80px;" >ADD FIELD+</a>
<%End if%>
<div id="fields_container">
<%If isGroup And numFields=0 then%>
	<div style="height:0px;" id="field_0_container"></div>
<%End if%>
<%If numFields = 0 And Not isGroup then%>
<div id="field_1_container">
<label for="cfDisplayName_1">Display Name</label>
<input type="text" name="cfDisplayName_1" id="cfDisplayName_1" value="">
<label for="cfDataType_1">Type</label>
<select id="cfDataType_1" name="cfDataType_1" onchange="if(this.value=='drop_down'){document.getElementById('cfDropDownHolder_1').style.display='block';}else{document.getElementById('cfDropDownHolder_1').style.display='none';}">
	<option value="-1">--- SELECT ---</option>
	<option value="int">Integer</option>
	<option value="float">Real Number</option>
	<option value="date">Date/Time</option>
	<option value="text">Text</option>
	<option value="long_text">Long Text</option>
	<option value="drop_down">Drop Down</option>
	<option value="file">File</option>
	<%If session("companyHasFTLiteReg") then%>
		<option value="multi_int">Multi Integer</option>
		<option value="multi_float">Multi Real Number</option>
	<%End if%>
	<option value="multi_text">Multi Text</option>
</select>

<div id="cfDropDownHolder_1" style="display:none;">
<label for="cfDropDownId_1">Drop Down</label>
<select id="cfDropDownId_1" name="cfDropDownId_1">
	<option value="-1">-- SELECT --</option>
	<%
	Call getconnected
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM regDropDowns WHERE companyId="&SQLClean(session("companyId"),"N","S")
	rec2.open strQuery,conn,3,3
	Do While Not rec2.eof
		%>
			<option value="<%=rec2("id")%>"><%=rec2("name")%></option>
		<%
		rec2.movenext
	Loop
	rec2.close
	Set rec2 = Nothing
	Call disconnect
	%>
<option value="-1">--------</option>
<option value="-99">User List</option>
</select>
</div>
		<div class="regCustomFieldOptions">
			<fieldset>
			<legend>Options</legend>
			<input type="checkbox" name="showBatch_1" id="showBatch_1" >Show for batch
			<input type="checkbox" name="showCompound_1" id="showCompound_1" >Show for compound
			<br/>
			<input type="checkbox" name="requireBatch_1" id="requireBatch_1" >Require for batch
			<input type="checkbox" name="requireCompound_1" id="requireCompound_1" >Require for compound
			<br/>
			<input type="checkbox" name="showBatchInput_1" id="showBatchInput_1" >Show for Add batch
			<input type="checkbox" name="showCompoundInput_1" id="showCompoundInput_1" >Show for Add compound
			<br/>
			<input type="checkbox" name="enforceUnique_1" id="enforceUnique_1" >Enforce Uniqueness
			<input type="checkbox" name="isIdentity_1" id="isIdentity_1">Is Identity
			<br/>
			<input type="checkbox" name="isLink_1" id="isLink_1">Is Linked Field
			</fieldset>
		</div>

</div>

<%Else
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
'5115 added field table var
If isGroup Then
	strQuery = "SELECT * FROM "&fieldFieldsTable&" WHERE groupId="&SQLClean(groupId,"N","S")

	hasRegSorting = checkBoolSettingForCompany("allowRegistrationSorting", session("companyId"))
	if hasRegSorting then
		strQuery = strQuery & " ORDER BY sortOrder ASC, ID ASC"
	end if

else
	strQuery = "SELECT * FROM customFields ORDER BY ID ASC"
End if
rec.open strQuery,jchemRegConn,3,3
counter = 0
Do While Not rec.eof
	counter = counter + 1
	%>
	<div id="field_<%=counter%>_container">
		<label for="cfDisplayName_<%=counter%>">Display Name</label>
		<input type="text" name="cfDisplayName_<%=counter%>" id="cfDisplayName_<%=counter%>" value="<%=rec("displayName")%>" readonly>
		<label for="cfDataType_<%=counter%>">Type</label>
		<select id="cfDataType_<%=counter%>" name="cfDataType_<%=counter%>" readonly>
			<%If rec("dataType")="int" then%><option value="int" SELECTED>Integer</option><%End if%>
			<%If rec("dataType")="float" then%><option value="float" SELECTED>Real Number</option><%End if%>
			<%If rec("dataType")="date" then%><option value="date" SELECTED>Date/Time</option><%End if%>
			<%If rec("dataType")="text" then%><option value="text" SELECTED>Text</option><%End if%>
			<%If rec("dataType")="long_text" then%><option value="long_text" SELECTED>Long Text</option><%End if%>
			<%If rec("dataType")="drop_down" then%><option value="drop_down" SELECTED>Drop Down</option><%End if%>
			<%If rec("dataType")="file" then%><option value="file" SELECTED>File</option><%End if%>
			<%If rec("dataType")="read_only" then%><option value="read_only" SELECTED>Read Only Text</option><%End if%> <%' This is for SAGE, they want a read only batch level field that the system will write%>
			<%If session("companyHasFTLiteReg") then%>
				<%If rec("dataType")="multi_int" then%><option value="multi_int" SELECTED>Multi Integer</option><%End if%>
				<%If rec("dataType")="multi_float" then%><option value="multi_float" SELECTED>Multi Real Number</option><%End if%>
			<%End if%>
			<%If rec("dataType")="multi_text" then%><option value="multi_text" SELECTED>Multi Text</option><%End if%>
		</select>
		
		<%If Not IsNull(rec("dropDownId")) then%>
		<%If CInt(rec("dropDownId")) > 0 Or CInt(rec("dropDownId"))=-99 then%>
		<div id="cfDropDownHolder_<%=counter%>">
		<label for="cfDropDownId_<%=counter%>">Drop Down</label>
		<select id="cfDropDownId_<%=counter%>" name="cfDropDownId_<%=counter%>" readonly>
			<%If CInt(rec("dropDownId"))=-99 then%>
				<option value="-99">User List</option>
			<%End if%>
			<%
			Call getConnectedJchemReg
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM regDropDowns WHERE  id="&SQLClean(rec("dropDownId"),"N","S")
			rec2.open strQuery,jchemRegConn,3,3
			Do While Not rec2.eof
				%>
					<option value="<%=rec2("id")%>" <%If CInt(rec("dropDownId")) = CInt(rec2("id")) then%>SELECTED<%End if%>><%=rec2("name")%></option>
				<%
				rec2.movenext
			Loop
			rec2.close
			Set rec2 = Nothing
			%>
		</select>
		</div>
		<%End if%>
		<%End if%>

		<input type="hidden" name="cfReadOnly_<%=counter%>" value="true">
		<input type="hidden" name="rowId_<%=counter%>" value="<%=rec("id")%>">
		<%'5115 added isSet hiding%>
		<div class="regCustomFieldOptions" <%If isSet then%>style="display:none;"<%End if%>>
			<fieldset>
			<legend>Options</legend>
			<input type="checkbox" name="showBatch_<%=counter%>" id="showBatch_<%=counter%>" <%If rec("showBatch") = 1 then%>CHECKED<%End if%>>Show for batch
			<input type="checkbox" name="showCompound_<%=counter%>" id="showCompound_<%=counter%>" <%If rec("showCompound") = 1 then%>CHECKED<%End if%>>Show for compound
			<br/>
			<input type="checkbox" name="requireBatch_<%=counter%>" id="requireBatch_<%=counter%>" <%If rec("requireBatch") = 1 then%>CHECKED<%End if%>>Require for batch
			<input type="checkbox" name="requireCompound_<%=counter%>" id="requireCompound_<%=counter%>" <%If rec("requireCompound") = 1 then%>CHECKED<%End if%>>Require for compound
			<br/>
			<%
			If Not IsNull(rec("showBatchinput")) Then
				showBatchInput = rec("showBatchinput")
			Else
				showBatchInput = ""
			End If
			If Not IsNull(rec("showCompoundinput")) Then
				showCompoundInput = rec("showCompoundInput")
			Else
				showCompoundInput = ""
			End if
			%>
			<input type="checkbox" name="showBatchInput_<%=counter%>" id="showBatchInput_<%=counter%>" <%If CStr(showBatchInput) = "1" then%>CHECKED<%End if%>>Show for Add batch
			<input type="checkbox" name="showCompoundInput_<%=counter%>" id="showCompoundInput_<%=counter%>" <%If CStr(showCompoundInput) = "1" then%>CHECKED<%End if%>>Show for Add compound
			<br/>
			<input type="checkbox" name="enforceUnique_<%=counter%>" id="enforceUnique_<%=counter%>" <%If rec("enforceUnique") = 1 then%>CHECKED<%End if%>>Enforce Uniqueness
			<input type="checkbox" name="isIdentity_<%=counter%>" id="isIdentity_<%=counter%>" <%If rec("isIdentity") = 1 then%>CHECKED<%End if%>>Is Identity
			<br/>
			<input type="checkbox" name="isLink_<%=counter%>" id="isLink_<%=counter%>" <%If rec("isLink") = 1 then%>CHECKED<%End if%>>Is Linked Field
			</fieldset>
		</div>
	</div>	
	<%
	rec.movenext
loop
rec.close
Set rec = nothing
Call disconnectJchemReg
End if%>
</div>
<%If isGroup then%>
<a href="javascript:void(0);" onClick="document.getElementById('addCustomFieldSelect').selectedIndex=0;showPopup('addCustomFieldDiv');return false;" class="greenNewButton" style="width:80px;" >ADD FIELD+</a>
<%else%>
<a href="javascript:void(0);" onClick="addNewField('');return false;" class="greenNewButton" style="width:80px;" >ADD FIELD+</a>
<%End if%>
<input type="hidden" name="cfNumFields" id="cfNumFields" value="<%=numFields%>">
<input type="submit" name="customFieldsSubmit" id="customFieldsSubmit" value="Save">
</form>

</div>
	<!-- #include file="../_inclds/footer-tool.asp"-->