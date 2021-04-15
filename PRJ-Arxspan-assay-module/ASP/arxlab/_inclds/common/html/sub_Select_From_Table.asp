<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%

'  SelectFromTable(selTable, abbrCol, dispCol,"u"&fields(i)(formName) & "-" & handleClickValue, value,dependColName,dependColValue,dependColType)
sub SelectFromTable(tableName, abbrCol, dispCol, selectName, currAbbr,dependColName,dependColValue,dependColType,isSupportAccount)
	If Left(selectName,5) <> "arole" And Left(selectName,5) <> "urole" then
		mw = 180
	Else
		mw = 320
	End if
	if isSupportAccount = true  And (Left(selectName,5)  = "urole" Or Left(selectName,8)  = "uenabled") then
	response.Write "<select id=""" & selectName & """ name=""" & selectName &""" class=""body"" style=""width:"&mw&"px;display:none;"">"
	else
	response.Write "<select id=""" & selectName & """ name=""" & selectName &""" class=""body"" style=""width:"&mw&"px;"">"
    end if


	if dependColType = "number" then
		response.Write "<option value=""-1"">--- Select ---</option>"
	else
		response.Write "<option value="""">--- Select ---</option>"
	end if

	if dependColValue <> "" and dependColName <> "" and dependColType <> "" then
		if dependColType = "text" then
			strQuery = "SELECT " & abbrCol & "," & dispCol & " FROM " & tableName & " WHERE "& dependColName & "='" & dependColValue &"'"
			if globalFilterKey <> "" And tableName <> "yesno" And tableName <> "roles" then
				strQuery = strQuery & " AND " & globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
			end if
			strQuery = strQuery &" ORDER BY " & dispCol
		end if
		if dependColType = "number" then
			strQuery = "SELECT " & abbrCol & "," & dispCol & " FROM " & tableName & " WHERE "& dependColName & "=" & dependColValue
			if globalFilterKey <> "" And tableName <> "yesno" And tableName <> "roles" then
				strQuery = strQuery & " AND " & globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
			end if
			strQuery = strQuery &" ORDER BY " & dispCol
		end if
	else
		strQuery = "SELECT " & abbrCol & "," & dispCol & " FROM " & tableName
			if globalFilterKey <> "" And tableName <> "yesno" And tableName <> "adminRoles"  And tableName <> "regRoles" And tableName <> "invRoles" And tableName <> "assayRoles" then
				strQuery = strQuery & " WHERE " & globalFilterKey & "=" & SQLClean(globalFilterValue,"N","S")
			end If
			If tableName = "adminRoles" Then
				If session("roleNumber") = "1" then
					strQuery = strQuery & " WHERE number>=" & SQLClean(session("roleNumber"),"N","S")
				End If
				If session("roleNumber") = "2" then
					strQuery = strQuery & " WHERE number>" & SQLClean(session("roleNumber"),"N","S")
				End If
				If session("roleNumber") = "3" then
					strQuery = strQuery & " WHERE number>" & SQLClean(session("roleNumber"),"N","S")
				End if			
			End If
			If tableName <> "adminRoles" And tableName <> "regRoles" And tableName <> "invRoles" And tableName <> "assayRoles" then
				strQuery = strQuery &" ORDER BY " & dispCol
			Else
				If tableName = "adminRoles" then
					strQuery = strQuery &" ORDER BY number ASC"
				End If
				If tableName = "regRoles" Or tableName = "invRoles" Or tableName = "assayRoles" then
					strQuery = strQuery &" ORDER BY roleNumber ASC"
				End if
			End if
	end if
	call getconnectedadm
	set rec_select_from = Server.CreateObject("ADODB.recordset")	
	rec_select_from.CursorLocation = 3
	'response.write(strQuery)
	rec_select_from.Open strQuery, ConnAdm, 3,3

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
	