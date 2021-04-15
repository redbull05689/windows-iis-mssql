<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
number=request.querystring("number")
If request.querystring("fieldId") <> "" Then
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM customFields WHERE id="&SQLClean(request.querystring("fieldId"),"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		foundField = true
		displayName = rec("displayName")
		dataType = rec("dataType")
		dropDownId = rec("dropDownId")
		showBatch = rec("showBatch")
		requireBatch = rec("requireBatch")
		showBatchInput = rec("showBatchInput")
		showCompound = rec("showCompound")
		requireCompound = rec("requireCompound")
		showCompoundInput = rec("showCompoundInput")
		enforceUnique = rec("enforceUnique")
		isIdentity = rec("isIdentity")
		isLink = rec("isLink")
		customFieldId = rec("id")
	Else foundField = false
	End if
	Call disconnectJchemReg
End if
%>
<label for="cfDisplayName_<%=number%>">Display Name</label>
<input type="text" name="cfDisplayName_<%=number%>" id="cfDisplayName_<%=number%>" value="<%=displayName%>" <%If foundField then%>readonly<%End if%>>
<label for="cfDataType_<%=number%>">Type</label>
<select id="cfDataType_<%=number%>" name="cfDataType_<%=number%>" onchange="if(this.value=='drop_down'){document.getElementById('cfDropDownHolder_<%=number%>').style.display='block';}else{document.getElementById('cfDropDownHolder_<%=number%>').style.display='none';}" <%If foundField then%>readonly<%End if%>>
<%If foundField then%>
	<%If dataType="int" then%><option value="int" SELECTED>Integer</option><%End if%>
	<%If dataType="float" then%><option value="float" SELECTED>Real Number</option><%End if%>
	<%If dataType="date" then%><option value="date" SELECTED>Date/Time</option><%End if%>
	<%If dataType="text" then%><option value="text" SELECTED>Text</option><%End if%>
	<%If dataType="long_text" then%><option value="long_text" SELECTED>Long Text</option><%End if%>
	<%If dataType="drop_down" then%><option value="drop_down" SELECTED>Drop Down</option><%End if%>
	<%If dataType="file" then%><option value="file" SELECTED>File</option><%End if%>
	<%If session("companyHasFTLiteReg") then%>
		<%If dataType="multi_int" then%><option value="multi_int" SELECTED>Multi Integer</option><%End if%>
		<%If dataType="multi_float" then%><option value="multi_float" SELECTED>Multi Real Number</option><%End if%>
	<%End if%>
	<%If dataType="multi_text" then%><option value="multi_text" SELECTED>Multi Text</option><%End if%>
<%else%>
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
<%End if%>
</select>
<%If Not foundField Or dataType="drop_down" then%>
<div id="cfDropDownHolder_<%=number%>" <%If Not foundField then%>style="display:none;"<%End if%>>
<label for="cfDropDownId_<%=number%>">Drop Down</label>
<select id="cfDropDownId_<%=number%>" name="cfDropDownId_<%=number%>">
	<%If Not foundField then%><option value="-1">-- SELECT --</option><%End if%>
	<%
	Call getconnectedJchemReg
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM regDropDowns ORDER BY name ASC"
	rec2.open strQuery,jchemRegConn,3,3
	Do While Not rec2.eof
		%>
			<%If foundField then%>
				<%If Not IsNull(dropDownId) then%>
					<%If CStr(dropDownId)=CStr(rec2("id")) then%>
						<option value="<%=rec2("id")%>"><%=rec2("name")%></option>
					<%End if%>
				<%End if%>
			<%else%>
				<option value="<%=rec2("id")%>"><%=rec2("name")%></option>
			<%End if%>
		<%
		rec2.movenext
	Loop
	rec2.close
	Set rec2 = Nothing
	Call disconnectJchemReg
	%>
<%If Not foundField then%>
	<option value="-1">--------</option>
	<option value="-99">User List</option>
<%End if%>
</select>
</div>
<%End if%>
<div class="regCustomFieldOptions">
	<%'5115 added display none for set%>
	<fieldset <%If request.querystring("set")="1" then%>style="display:none;"<%End if%>>
	<legend>Options</legend>
	<input type="checkbox" name="showBatch_<%=number%>" id="showBatch_<%=number%>" <%If showBatch="1" then%>checked<%End if%>>Show for batch
	<input type="checkbox" name="showCompound_<%=number%>" id="showCompound_<%=number%>" <%If showCompound="1" then%>checked<%End if%>>Show for compound
	<br/>
	<input type="checkbox" name="requireBatch_<%=number%>" id="requireBatch_<%=number%>" <%If requireBatch="1" then%>checked<%End if%>>Require for batch
	<input type="checkbox" name="requireCompound_<%=number%>" id="requireCompound_<%=number%>" <%If requireCompound="1" then%>checked<%End if%>>Require for compound
	<br/>
	<input type="checkbox" name="showBatchInput_<%=number%>" id="showBatchInput_<%=number%>" <%If showBatchInput="1" then%>checked<%End if%>>Show for Add batch
	<input type="checkbox" name="showCompoundInput_<%=number%>" id="showCompoundInput_<%=number%>" <%If showCompoundInput="1" then%>checked<%End if%>>Show for Add compound
	<br/>
	<input type="checkbox" name="enforceUnique_<%=number%>" id="enforceUnique_<%=number%>" <%If enforceUnique="1" then%>checked<%End if%>>Enforce Uniqueness
	<input type="checkbox" name="isIdentity_<%=number%>" id="isIdentity_<%=number%>">Is Identity
	<br/>
	<input type="checkbox" name="isLink_<%=number%>" id="isLink_<%=number%>">Is Linked Field
	<%If foundField then%>
	<input type="hidden" name="cfId_<%=number%>" value="<%=customFieldId%>">
	<%End if%>
	</fieldset>
</div>