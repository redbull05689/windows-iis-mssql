<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->
<!-- #include file="_inclds/lib_reg.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
sectionId = "reg"
subSectionId = "import"
subSubSectionId = "map-fields"
if Not session("regRegistrar") Then
	response.redirect("logout.asp")
End If
%>
<%
	fid = request.querystring("fid")
	filename = session("regUploadfilename")
	fullpath = session("regUploadFullPath")
	fileExtension = Split(filename,".")(UBound(Split(filename,".")))
%>

<%
useSalts = True
hasStructure = True
allowBatches = True
groupId = request.querystring("groupId")
If isInteger(request.querystring("groupId")) And groupId <> "0" Then
	isGroup = True
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT useSalts, hasStructure, allowBatches FROM groupCustomFields WHERE id="&SQLClean(groupId,"N","S")
	If session("regRestrictedGroups") <> "" Then
		strQuery = strQuery & " AND id NOT IN ("&session("regRestrictedGroups")&")"
	End if
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		If rec("useSalts") = 0 Then
			useSalts = False
		End if	
		If rec("hasStructure") = 0 Then
			hasStructure = False
		End If
		If rec("allowBatches") = 0 Then
			allowBatches = False
		End if
	Else
		title = "Error"
		message = "Group does not exist or you are not authorized to access it."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
	End if
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg
Else
	isGroup = False
End if

' Cannot upload a SD file for any object that does not have a Structure field.
If LCase(fileExtension) = "sdf" And hasStructure = False Then
	response.redirect(mainAppPath&"/static/errorMessage.asp?title=File Upload Error&message=You cannot upload '.sdf' file for Group that does not have a Structure field.")
End If
%>

<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<script type="text/javascript">
function saveTemplate()
{
	counter = 0
	qStr = ""
	for (i=1;i<200 ;i++ )
	{
		sdName = document.getElementById("mfName_"+i)
		if (!sdName)
		{
			break;
		}
		sdName = sdName.value
		regName = document.getElementById("regName_"+i).options[document.getElementById("regName_"+i).selectedIndex].value.split("|||")[1]
		regValue = document.getElementById("regName_"+i).options[document.getElementById("regName_"+i).selectedIndex].value

		hasDefault = document.getElementById("defaultValueAdded_"+i).value
		if (hasDefault == "1")
		{
			defaultValue = document.getElementById("defaultValue_"+i).value
		}
		else
		{
			defaultValue = ""
		}

		if(document.getElementById("appendData_"+i).checked){
			appendData = "1"
		}else{
			appendData = "0"
		}

		if (regValue)
		{
			counter += 1
			qStr += "sdName_" + counter + "=" + escape(sdName)+"&";
			qStr += "regName_" + counter + "=" + escape(regName) +"&";
			qStr += "hasDefault_" + counter + "=" + escape(hasDefault) +"&";
			qStr += "defaultValue_" + counter + "=" + escape(defaultValue) +"&";
			qStr += "appendData_" + counter + "=" + escape(appendData) +"&";
		}
	}
	qStr += "numFields="+counter
	templateName = ""
	while (templateName == "")
	{
		templateName = prompt("Template Name")
		if (templateName==""){alert("Please Enter a Name")}
	}
	if (templateName != null)
	{
		qStr += "&templateName="+escape(templateName)
		ret = getFile("mappingTemplatesSave.asp?"+qStr)
		if (ret == "success")
		{
			alert("Template Saved")
		}
		else
		{
			alert(ret)
		}
	}
}

var selectFields
var sdFileFields

selectFields = []
sdFileFields = []

selectFields.push(['','None'])
selectFields.push(['',''])
selectFields.push(['','SYSTEM'])
selectFields.push(['','------------'])
selectFields.push(['chemical_name|||Chemical Name','Chemical Name'])
selectFields.push(['date_created|||Date Created','Date Created'])
selectFields.push(['name|||Name','Name'])
selectFields.push(['user_name|||User Name','User Name'])
<%if request.querystring("makeBatches") <> "REPLACE_ON_KEY" then%>
selectFields.push(['projectId|||projectId','Project'])
<%end if%>
<%
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
if isGroup then
    strQuery = "SELECT requireBatch, actualField, displayName FROM groupCustomFieldFields WHERE dataType != 'file' and (requireBatch=1 or showBatch=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY displayName"
else
    strQuery = "SELECT requireBatch, actualField, displayName FROM customFields WHERE dataType != 'file' and (requireBatch=1 or showBatch=1) ORDER BY displayName"
end if
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
%>
selectFields.push(['',''])
selectFields.push(['','BATCH'])
selectFields.push(['','------------'])
<%
End if
Do While Not rec.eof
	required = "*"
	If rec("requireBatch") <> 1 Then
		required = ""
	End if%>
	selectFields.push(['<%=rec("actualField")&"|||"&replace(rec("displayName"),"'","\'")%>','<%=replace(rec("displayName"),"'","\'")&required%>'])
	<%
	rec.movenext
Loop
rec.close
Set rec = Nothing
Call disconnectJchemReg

Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
if isGroup then
    strQuery = "SELECT requireCompound, actualField, displayName FROM groupCustomFieldFields WHERE dataType != 'file' and (requireCompound=1 or showCompound=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY displayName"
else
    strQuery = "SELECT requireCompound, actualField, displayName FROM customFields WHERE dataType != 'file' and (requireCompound=1 or showCompound=1) ORDER BY displayName"
end if
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
%>
selectFields.push(['',''])
selectFields.push(['','COMPOUND'])
selectFields.push(['','------------'])
<%
End if
Do While Not rec.eof
	required = "*"
	If rec("requireCompound") <> 1 Then
		required = ""
	End if
	%>
	selectFields.push(['<%=rec("actualField")&"|||"&replace(rec("displayName"),"'","\'")%>','<%=replace(rec("displayName"),"'","\'")&required%>'])
	<%
	rec.movenext
Loop
rec.close
Set rec = Nothing
Call disconnectJchemReg

Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
if isGroup then
    strQuery = "SELECT actualField, displayName FROM groupCustomFieldFields WHERE dataType != 'file' and (requireCompound=1 or showCompound=1) and (requireBatch=1 or showBatch=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY displayName"
else
    strQuery = "SELECT actualField, displayName FROM customFields WHERE dataType != 'file' and  (requireCompound=1 or showCompound=1) and (requireBatch=1 or showBatch=1) ORDER BY displayName"
end if
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
%>
selectFields.push(['',''])
selectFields.push(['','BOTH'])
selectFields.push(['','------------'])
<%
End if
Do While Not rec.eof
	%>
		selectFields.push(['<%=rec("actualField")&"|||"&replace(rec("displayName"),"'","\'")%>','<%=replace(rec("displayName"),"'","\'")&required%>'])
	<%
	rec.movenext
Loop
rec.close
Set rec = Nothing
Call disconnectJchemReg
%>

function contains(a, obj) {
    var i = a.length;
    while (i--) {
       if (a[i] === obj) {
           return true;
       }
    }
    return false;
}

function loadTemplate(el,caller)
{
	if (el.value != "")
	{
		theString = el.options[el.selectedIndex].value
		pairs = theString.split("###")
		numberSet = 0
		for (i=0;i<pairs.length ;i++ )
		{
			pair = pairs[i]
			sdName = pair.split("|||")[0]
			regName = pair.split("|||")[1]
			for (j=1;j<200 ;j++ )
			{
				thisSdName = document.getElementById("mfName_"+j)
				if (!thisSdName)
				{
					break;
				}
				thisSdName = thisSdName.value
				thisRegName = document.getElementById("regName_"+j).options[document.getElementById("regName_"+j).selectedIndex].value.split("|||")[1]
				thisRegEl = document.getElementById("regName_"+j)
				if (sdName == thisSdName)
				{
					for (k=0;k<thisRegEl.length ;k++ )
					{
						if (thisRegEl.options[k].value.split("|||")[1] == regName)
						{
							thisRegEl.selectedIndex = k
						}
					}
					numberSet +=1
					if (pair.split("|||")[2]=="1")
					{
						document.getElementById("defaultValue_"+j).style.display = "inline";
						document.getElementById("defaultValue_"+j).value = pair.split("|||")[3];
						document.getElementById("defaultValueAdded_"+j).value = "1";
						document.getElementById("defaultValueToggleLink_"+j).innerHTML = "Remove Default";
						if(thisRegEl.options[thisRegEl.selectedIndex].value.split("_")[0] == "t"){
							cb = document.getElementById("appendData_"+j);
							cbLabel = document.getElementById("appendDataLabel_"+j);
							<%if request.querystring("makeBatches") = "REPLACE_ON_KEY" then%>
							cb.style.display = "inline";
							cbLabel.style.display = "inline";
							<%end if%>
							if(pair.split("|||")[4]=="1"){
								document.getElementById("appendData_"+j).checked = true;
							}
						}else{
							cb = document.getElementById("appendData_"+j);
							cbLabel = document.getElementById("appendDataLabel_"+j);
							cb.style.display = "none";
							cbLabel.style.display = "none";
						}
					}
					else
					{
						document.getElementById("defaultValue_"+j).style.display = "none";
						document.getElementById("defaultValue_"+j).value = "";
						document.getElementById("defaultValueAdded_"+j).value = "0";
						document.getElementById("defaultValueToggleLink_"+j).innerHTML = "Create Default";
						if(thisRegEl.options[thisRegEl.selectedIndex].value.split("_")[0] == "t"){
							cb = document.getElementById("appendData_"+j);
							cbLabel = document.getElementById("appendDataLabel_"+j);
							<%if request.querystring("makeBatches") = "REPLACE_ON_KEY" then%>
							cb.style.display = "inline";
							cbLabel.style.display = "inline";
							<%end if%>
							if(pair.split("|||")[3]=="1"){
								document.getElementById("appendData_"+j).checked = true;
							}
						}else{
							cb = document.getElementById("appendData_"+j);
							cbLabel = document.getElementById("appendDataLabel_"+j);
							cb.style.display = "none";
							cbLabel.style.display = "none";
						}
					}
				}
			}
		}
		if (numberSet < pairs.length)
		{
			if (caller == "me")
			{
				addFields = true
			}
			else{
			addFields = confirm("Warning not all SD File fields from template exist in this SD File.  Would you like them added to this mapping?")
			}
			if (addFields)
			{
				for (i=0;i<pairs.length ;i++ )
				{
					pair = pairs[i]
					sdName = pair.split("|||")[0]
					if (!contains(sdFileFields,sdName))
					{
						addField(pair,sdName)
						loadTemplate(el,"me")
					}
				}
			}
		}
	}
}
function addField(pair,sdName)
{
	lastNum = 1
	for (i=1;i<200 ;i++ )
	{
		if (document.getElementById("holder_"+i))
		{
			lastNum = i
		}
		else{break;}
	}
	lastNum += 1
	theDiv = document.createElement("div")
	theDiv.setAttribute("id","holder_"+lastNum)
	theDiv.setAttribute("name","holder_"+lastNum)

	theSelect = document.createElement("select")
	theSelect.setAttribute("name","regName_"+lastNum)
	theSelect.setAttribute("id","regName_"+lastNum)
	for (i=0;i<selectFields.length ;i++ )
	{
		theOption = document.createElement("option")
		theText = document.createTextNode(selectFields[i][1])
		theOption.appendChild(theText)
		theOption.setAttribute("value",selectFields[i][0])
		theSelect.appendChild(theOption)
	}
	theSelect.setAttribute("onclick","checkFieldType('regName_"+lastNum+"')")
	theSpan = document.createElement("span")
	theText = document.createTextNode(sdName+" -> ")
	theSpan.appendChild(theText)

	theHiddenDefaultValue = document.createElement("input")
	theHiddenDefaultValue.setAttribute("type","hidden")
	theHiddenDefaultValue.setAttribute("name","defaultValueAdded_"+lastNum)
	theHiddenDefaultValue.setAttribute("id","defaultValueAdded_"+lastNum)
	if (pair.split("|||")[2] == "1")
	{
		theHiddenDefaultValue.setAttribute("value","1")
	}
	else
	{
		theHiddenDefaultValue.setAttribute("value","0")
	}

	appendDataLabel = document.createElement("label")
	appendDataLabel.appendChild(document.createTextNode("Append Data:"))
	appendDataLabel.setAttribute("name","appendDataLabel_"+lastNum)
	appendDataLabel.setAttribute("id","appendDataLabel_"+lastNum)
	appendDataLabel.setAttribute("for","appendData_"+lastNum)

	appendDataCheckbox = document.createElement("input")
	appendDataCheckbox.setAttribute("type","checkbox")
	appendDataCheckbox.setAttribute("name","appendData_"+lastNum)
	appendDataCheckbox.setAttribute("id","appendData_"+lastNum)

	defaultText = document.createElement("input")
	defaultText.setAttribute("type","text")
	defaultText.setAttribute("name","defaultValue_"+lastNum)
	defaultText.setAttribute("id","defaultValue_"+lastNum)
	if (pair.split("|||")[2] == "1")
	{
		defaultText.setAttribute("value",pair.split("|||")[3])
		defaultText.style.display = "inline"
		if(pairs.split("|||")[4] == "1"){
		}
	}
	else
	{
		defaultText.setAttribute("value","")
		defaultText.style.display = "none"
	}

	defaultLink = document.createElement("a")
	defaultLink.setAttribute("name","defaultValueToggleLink_"+lastNum)
	defaultLink.setAttribute("id","defaultValueToggleLink_"+lastNum)
	defaultLink.setAttribute("onclick","toggleDefaultValue("+lastNum+")")
	defaultLink.setAttribute("href","javascript:void(0)")
	if (pair.split("|||")[2] == "1")
	{
		defaultLink.innerHTML = "Remove Default"
	}
	else
	{
		defaultLink.innerHTML = "Create Default"
	}

	theHidden = document.createElement("input")
	theHidden.setAttribute("type","hidden")
	theHidden.setAttribute("name","mfName_"+lastNum)
	theHidden.setAttribute("id","mfName_"+lastNum)
	theHidden.setAttribute("value",sdName)

	theDiv.appendChild(theSpan)
	theDiv.appendChild(theSelect)
	theDiv.appendChild(theHidden)
	theDiv.appendChild(theHiddenDefaultValue)
	theDiv.appendChild(defaultText)
	theDiv.appendChild(defaultLink)
	theDiv.appendChild(appendDataLabel)
	theDiv.appendChild(appendDataCheckbox)

	document.getElementById("holders_holder").appendChild(theDiv)
	sdFileFields.push(sdName)
	document.getElementById("numFields").value = parseInt(document.getElementById("numFields").value) + 1
}

function checkFieldType(elId){
	el = document.getElementById(elId);
	counter = elId.split("_")[1];
	cb = document.getElementById("appendData_"+counter);
	cbLabel = document.getElementById("appendDataLabel_"+counter);
	if(el.options[el.selectedIndex].value.split("_")[0] == "t"){
		<%if request.querystring("makeBatches") = "REPLACE_ON_KEY" then%>
		cb.style.display = "inline";
		cbLabel.style.display = "inline";
		<%end if%>
	}else{
		cb.checked = false;
		cb.style.display = "none";
		cbLabel.style.display = "none";
	}
}
</script>
<%
If request.querystring("replaceKey") <> "-1" Then
Call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM customFields WHERE actualField="&SQLClean(request.querystring("replaceKey"),"T","S")
rec.open strQuery,jchemRegConn,3,3
If Not rec.eof Then
	replaceKeyName = rec("displayName")
Else
	If request.querystring("replaceKey") = "reg_id" Then
		replaceKeyName = "reg_id"
	End if
End if
rec.close
Set rec = Nothing

Call disconnectJchemReg
End if
%>
<script type="text/javascript">
function validateForm()
{
	replaceKey = document.getElementById("replaceKey").value
	if (replaceKey == "-1")
	{
		return true;
	}

	els = document.getElementById("mapFieldsForm").getElementsByTagName("select")
	for (i=0;i<els.length ;i++ )
	{
		if(els[i].options[els[i].selectedIndex].value.indexOf("|||") > -1)
		{
			if(els[i].options[els[i].selectedIndex].value.split("|||")[0]==replaceKey)
			{
				return true;
			}
		}
	}
	alert("<%=replaceKeyName%> must be mapped");
	return false;
}
</script>

<script type="text/javascript">
function toggleDefaultValue(c)
{
	if (document.getElementById("defaultValue_"+c).style.display=="none")
	{
		document.getElementById("defaultValue_"+c).style.display = "inline";
		document.getElementById("defaultValueToggleLink_"+c).innerHTML = "Remove Default"
		document.getElementById("defaultValueAdded_"+c).value = "1";
	}
	else
	{
		document.getElementById("defaultValue_"+c).style.display = "none";
		document.getElementById("defaultValueToggleLink_"+c).innerHTML = "Create Default"
		document.getElementById("defaultValueAdded_"+c).value = "0";
	}
}
</script>

<div class="registrationPage">
<h1>Import Field Mapping</h1>
<strong>Template:</strong>
<select onchange="loadTemplate(this,'')">
	<option value="">-- SELECT --</option>
	<%
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id, templateName FROM mappingTemplates WHERE userId="&SQLClean(session("userId"),"N","S")& " OR userId=0 ORDER BY templateName"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		thisOptionText = rec("templateName")
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM mappingTemplateOptions WHERE templateId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,jchemRegConn,3,3
		thisOptionValueString = ""
		Do While Not rec2.eof
			thisOptionValueString = thisOptionValueString & rec2("sdName") &"|||"& rec2("fieldName")
			thisOptionValueString = thisOptionValueString & "|||"
			If Not IsNull(rec2("defaultExists")) then
				If CStr(rec2("defaultExists")) = "1" Then
					thisOptionValueString = thisOptionValueString & "1|||"&rec2("defaultValue")
				Else
					thisOptionValueString = thisOptionValueString & "0|||"
				End if
			Else
				thisOptionValueString = thisOptionValueString & "0|||"
			End If
			If IsNull(rec2("appendData")) Then
				thisOptionValueString = thisOptionValueString & "0|||"	
			Else
				If rec2("appendData") = "1" Then
					thisOptionValueString = thisOptionValueString & "1|||"					
				Else
					thisOptionValueString = thisOptionValueString & "0|||"				
				End if
			End if
			rec2.movenext
			If Not rec2.eof Then
				thisOptionValueString = thisOptionValueString & "###"
			End if
		Loop
		rec2.close
		Set rec2 = Nothing
	%>
		<option value="<%=thisOptionValueString%>"><%=thisOptionText%></option>
	<%
		rec.movenext
	loop
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg
	%>
</select>
<br><br>
<%'QQQ whole select making is new%>
<form method="post" action="importImport.asp?fid=<%=fid%>&makeBatches=<%=request.querystring("makeBatches")%>&source=<%=request.querystring("source")%>&groupId=<%=request.querystring("groupId")%>&sdId=<%=request.querystring("sdId")%>" onsubmit="return validateForm()" id="mapFieldsForm">
	<div id="holders_holder">
<%
	selectOptions = "<option value=''>None</option><option value=''></option><option value=''>SYSTEM</option><option value=''>------------</option><option value='chemical_name|||Chemical Name'>Chemical Name</option><option value='date_created|||Date Created'>Date Created</option><option value='name|||Name'>Name</option><option value='user_name|||User Name'>User Name</option><option value='projectId|||projectId'>Project</option>"

	If replaceKeyName = "reg_id" Then
		selectOptions = selectOptions & "<option value='reg_id|||Registration Id'>Registration Id</option>"
	End if

	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT requireBatch, actualField, displayName FROM groupCustomFieldFields WHERE dataType != 'file' and (requireBatch=1 or showBatch=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY displayName"	
	else
		strQuery = "SELECT requireBatch, actualField, displayName FROM customFields WHERE dataType != 'file' and (requireBatch=1 or showBatch=1) ORDER BY displayName"
	End if
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		selectOptions = selectOptions & "<option value=''></option><option value=''>BATCH</option><option value=''>------------</option>"
	End if
	Do While Not rec.eof
		required = "*"
		If rec("requireBatch") <> 1 Then
			required = ""
		End if
		selectOptions = selectOptions & "<option value="""&rec("actualField")&"|||"&Server.HTMLEncode(rec("displayName"))&""">"&rec("displayName")&required&"</option>"
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg

	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT requireCompound, actualField, displayName FROM groupCustomFieldFields WHERE dataType != 'file' and (requireCompound=1 or showCompound=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY displayName"	
	else
		strQuery = "SELECT requireCompound, actualField, displayName FROM customFields WHERE dataType != 'file' and (requireCompound=1 or showCompound=1) ORDER BY displayName"
	End if
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		selectOptions = selectOptions & "<option value=''></option><option value=''>COMPOUND</option><option value=''>------------</option>"
	End if
	Do While Not rec.eof
		required = "*"
		If rec("requireCompound") <> 1 Then
			required = ""
		End if
		selectOptions = selectOptions & "<option value="""&rec("actualField")&"|||"&Server.HTMLEncode(rec("displayName"))&""">"&rec("displayName")&required&"</option>"
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg

	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	If isGroup Then
		strQuery = "SELECT actualField, displayName FROM groupCustomFieldFields WHERE dataType != 'file' and (requireCompound=1 or showCompound=1) and (requireBatch=1 or showBatch=1) and groupId="&SQLClean(groupId,"N","S")&" ORDER BY displayName"	
	else
		strQuery = "SELECT actualField, displayName FROM customFields WHERE dataType != 'file' and (requireCompound=1 or showCompound=1) and (requireBatch=1 or showBatch=1) ORDER BY displayName"
	End if

	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		selectOptions = selectOptions & "<option value=''></option><option value=''>BOTH</option><option value=''>------------</option>"
	End if
	Do While Not rec.eof
		selectOptions = selectOptions & "<option value="""&rec("actualField")&"|||"&Server.HTMLEncode(rec("displayName"))&""">"&rec("displayName")&"</option>"
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	Call disconnectJchemReg

	bulkRegEndpointUrl = getCompanySpecificSingleAppConfigSetting("bulkRegEndpointUrl", session("companyId"))
	payload = "{""filePath"":"""&fullpath&"""}"
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.open "POST", bulkRegEndpointUrl&"/getUploadFields", True
	http.setRequestHeader "Content-Type", "application/json"
	http.setRequestHeader "Content-Length", Len(payload)
	http.SetTimeouts 180000,180000,180000,180000
	' ignore ssl cert errors
	http.setOption 2, 13056
	http.send payload
	' Handle HTTP exception
	Err.Clear
	On Error Resume Next
	http.waitForResponse(180)

	If Err.Number <> 0 Then
		title = "Error"
		message = "There seems to be an issue with the Bulk Upload Service. Please try again or contact Arxspan Support if the problem persists."
		response.redirect(mainAppPath&"/static/errorMessage.asp?title="&title&"&message="&message)
		response.End
	End If
	On Error GoTo 0

	Set jsonResp = JSON.Parse(http.responseText)
	Set dicTemp = jsonResp.Get("uploadFields")

	counter = 0
	Do While counter < dicTemp.length
		field = dicTemp.Get(counter)
		counter = counter + 1
		%>
		<script type="text/javascript">
            sdFileFields.push("<%=field%>")
        </script>
		<div id="holder_<%=counter%>">
		<span><%=field%>&nbsp;-&gt;&nbsp</span><select id="regName_<%=counter%>" name="regName_<%=counter%>" onclick="checkFieldType('regName_<%=counter%>')"><%=selectOptions%></select>
		<input type="text" name="defaultValue_<%=counter%>" id="defaultValue_<%=counter%>" style="display:none;">
		<a href="javascript:void(0)" onclick="toggleDefaultValue(<%=counter%>)" id="defaultValueToggleLink_<%=counter%>">Create Default</a>
		<label for="appendData_<%=counter%>" id="appendDataLabel_<%=counter%>" style="display:none;">Append Data:</label>
		<input type="checkbox" name="appendData_<%=counter%>" id="appendData_<%=counter%>" style="display:none;">
		<input type="hidden" name="defaultValueAdded_<%=counter%>" id="defaultValueAdded_<%=counter%>" value="0">
		<br/>
		<input type="hidden" name="mfName_<%=counter%>" id="mfName_<%=counter%>" value="<%=field%>">
		</div>
		<%
	Loop
%>
	</div>
	<input type="hidden" name="numFields" id="numFields" value="<%=counter%>">
	<input type="hidden" name="makeBatches" id="makeBatches" value="<%=request.querystring("makeBatches")%>">
	<input type="hidden" name="needsPurification" id="needsPurification" value="<%=request.querystring("needsPurification")%>">
	<input type="hidden" name="originalFilename" id="originalFilename" value="<%=request.querystring("originalFilename")%>">
	<input type="hidden" name="replaceKey" id="replaceKey" value="<%=request.querystring("replaceKey")%>">
	<input type="button" name="templateButton" id="templateButton" value="ADD TEMPLATE" style="margin-right:20px;" onclick="saveTemplate()">
	<input type="submit" name="mapSubmit" id="mapSubmit" value="CONTINUE">
</form>
</div>

<!-- #include file="../_inclds/footer-tool.asp"-->