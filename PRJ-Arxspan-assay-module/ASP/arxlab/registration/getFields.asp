<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%
sectionId = "reg"
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
if (Not (session("regRegistrar") Or session("regUser")) Or session("regRestrictedUser")) Then
	response.redirect("logout.asp")
End If
%>

<%
	selectOptions = "[[""chemical_name"",""Chemical Name"",""text""],[""cd_timestamp"",""Date Created"",""date""],[""cd_molweight"",""Molecular Weight"",""float""],[""name"",""Name"",""text""],[""user_name"",""User Name"",""text""],[""reg_id"",""Registration Id"",""text""],[""just_reg"",""Compound Number"",""text""],[""just_batch"",""Batch Number"",""float""],[""salt"",""Salts"",""drop_down""],[""source"",""Registration Source"",""text""],"

	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id,name FROM groupCustomFields WHERE name is not null AND visible<>0"
	If session("regRestrictedGroups") <> "" Then
		strQuery = strQuery & " AND id not in ("&session("regRestrictedGroups")&")"
	End If
	strQuery = strQuery &" ORDER BY name ASC"
	rec.open strQuery,jchemRegConn,3,3
	wasBlank = False
	If Not rec.eof Then
		selectOptions = selectOptions & "[""groupId"",""Field Group"",""drop_down""],"
	End if
	rec.close
	Set rec = Nothing
	selectOptions = selectOptions & "[""projectId"",""Project"",""drop_down""],"
	
	selectOptions = selectOptions & "["" "","" "",""text""],"

	Set rec = server.CreateObject("ADODB.RecordSet")

	strQuery = "SELECT * FROM customFields ORDER BY displayName"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		If rec("dataType") = "long_text" Or rec("dataType")="multi_text" Then
			dataType = "text"
		else
			dataType = rec("dataType")
		End If
		selectOptions = selectOptions & "["""&Replace(rec("actualField"),"""","\""")&""","""&Replace(rec("displayName"),"""","\""")&""","""&dataType&"""]"
		rec.movenext
		If Not rec.eof Then 
			selectOptions = selectOptions & ","
		End if
	Loop
	rec.close
	Set rec = nothing
	Call disconnectJchemReg

	selectOptions = selectOptions & "]"
	response.write(selectOptions)
%>