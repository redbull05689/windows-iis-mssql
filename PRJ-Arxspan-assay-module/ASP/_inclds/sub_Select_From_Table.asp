<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
sub SelectFromTable(tableName, abbrCol, dispCol, selectName, currAbbr,dependColName,dependColValue,dependColType)

	response.Write "<select id=""" & selectName & """ name=""" & selectName &""" class=""body"" style=""width:180px"">"
	if dependColType = "number" then
		response.Write "<option value=""-1"">--- Select ---</option>"
	else
		response.Write "<option value="""">--- Select ---</option>"
	end if

	if dependColValue <> "" and dependColName <> "" and dependColType <> "" then
		if dependColType = "text" then
			strQuery = "SELECT " & abbrCol & "," & dispCol & " FROM " & tableName & " WHERE "& dependColName & "='" & dependColValue &"' ORDER BY " & dispCol
		end if
		if dependColType = "number" then
			strQuery = "SELECT " & abbrCol & "," & dispCol & " FROM " & tableName & " WHERE "& dependColName & "=" & dependColValue &" ORDER BY " & dispCol
		end if
	else
		strQuery = "SELECT " & abbrCol & "," & dispCol & " FROM " & tableName & " ORDER BY " & dispCol
	end if
	call getconnectedadm
	set rec_select_from = Server.CreateObject("ADODB.recordset")	
	rec_select_from.CursorLocation = adUseClient
	rec_select_from.Open strQuery, ConnAdm, adOpenForwardOnly, adLockBatchOptimistic

	do while not rec_select_from.eof
		dbVal = rec_select_from(abbrCol)
		If IsNull(dbVal) Then
			dbVal = ""
		End If
		If IsNull(currAbbr) Then
			currAbbr = ""
		End if		
		%>	
		<option value="<%=rec_select_from(abbrCol)%>" <%if CStr(trim(dbVal)) = CStr(trim(currAbbr)) then%>SELECTED<%end if%>><%=rec_select_from(dispCol)%></option>
		<%
		rec_select_from.movenext
	loop
	rec_select_from.close
	set rec_select_from = nothing
	call disconnectadm
	
	response.Write "</select>"
end sub	
%>						
	