<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
	<%
regBatchNumberLength = getCompanySpecificSingleAppConfigSetting("regBatchNumberLength", session("companyId"))
regBatchNumberLength = normalizeIntSetting(regBatchNumberLength)
regNumberLength = getCompanySpecificSingleAppConfigSetting("regIdNumberLength", session("companyId"))
regNumberLength = normalizeIntSetting(regNumberLength)
regSaltsView = getCompanySpecificSingleAppConfigSetting("regSaltMappingView", session("companyId"))
Function MultiTrim (Byval TextData)
    Dim textRegExp
    Set textRegExp = new regexp
    textRegExp.Pattern = "\s{0,}(\S{1}[\s,\S]*\S{1})\s{0,}"
    textRegExp.Global = False
    textRegExp.IgnoreCase = True
    textRegExp.Multiline = True

    If textRegExp.Test (TextData) Then
    	MultiTrim = textRegExp.Replace (TextData, "$1")
    Else
    	MultiTrim = Trim(TextData)
    End If
End Function

		Dim j
		fields = Split(request.Form("fields"),",")
		firstGroup = -1
		lastGroupNumber = -1
		qStr = "("
		For i = 0 To UBound(fields)
			groupNumber = Split(fields(i),"_")(0)
			fieldNumber = Split(fields(i),"_")(1)
			fieldError = false
			If firstGroup = -1 Then
				firstGroup = groupNumber
			End If
			fieldType = SQLClean(request.Form("fieldType_"&groupNumber&"_"&fieldNumber),"TP","S")
			If groupNumber <> lastGroupNumber Then
				If groupNumber <> firstGroup Then
					qStr = qStr & ") " & SQLClean(request.Form("contraction_"&groupNumber),"TP","S") & " ("
				Else
					qStr = qStr & "("
				End If
				field = SQLClean(request.Form("field_"&groupNumber&"_"&fieldNumber),"TP","S")
				qualifier = SQLClean(request.Form("qualifier_"&groupNumber&"_"&fieldNumber),"TP","S")
				value = MultiTrim(request.Form("value_"&groupNumber&"_"&fieldNumber))
				If field = "just_reg" Then
					value = padWithZeros(value,regNumberLength)
				End if
				value = SQLClean(value,"TP","S")
				If qualifier = "not_like" then
					qualifier = "not like"
				End if
				'int float date text long_text drop_down
				'lt lte gt gte eq neq like
				Select Case qualifier
					Case "eq"
						If field = "salt" Then
							qualifier = "in"
						else
							qualifier = "="
							If sqlLikeMode then
								qualifier = "LIKE"
							End if
						End if
					Case "neq"
						If field = "salt" Then
							qualifier = "not in"
						else
							If sqlLikeMode then
								qualifier = "NOT LIKE"
							Else
								qualifier = "<>"
							End if
						End if
				End select
				If fieldType = "text" Or fieldType = "drop_down" Or fieldType = "long_text" Then
					If field <> "salt" then
						value = "'"&value&"'"
					End if
				End If
				If (qualifier = "like" Or qualifier="not like") And value <> "null" Then
					value = "'%"&Mid(value,2,Len(value)-2)&"%'"
				End If
				If qualifier = "in" And field<>"salt" Then
					list = Split(Mid(value,2,Len(value)-2),",")
					value = "("
					for q = 0 To UBound(list)
						If field="just_reg" Then
							value = value & SQLClean(padWithZeros(Trim(list(q)),regNumberLength),"T","S")						
						Else
							If field="reg_id" Then
								value = value & SQLClean(padWithZeros(Trim(list(q)),regNumberLength)&"-"&padWithZeros(0,regBatchNumberLength),"T","S")&","
							End if
							value = value & SQLClean(Trim(list(q)),"T","S")
						End if
						If q < UBound(list) Then
							value = value & ","
						end if
					Next
					value = value & ")"
				End if
			
				If fieldType = "int" Or fieldType = "float" Or fieldType="date" Or fieldType = "actual_number" Then
					Select Case qualifier
						Case "lt"
							qualifier = "<"
						Case "lte"
							qualifier = "<="
						Case "gt"
							qualifier = ">"
						Case "gte"
							qualifier = ">="
					End Select
					If fieldType <> "date" Then
						If InStr(field,"|")=-1 then
							value = "dbo.RemoveNonNumericChar("&value&")"

							If fieldType <> "actual_number" then
								If field <> "cd_molweight" then
									field = "dbo.RemoveNonNumericChar("&field&")"
								End if
							Else
								'If InStr(field,"|")<=0 Then
								'	field = "dbo.RemoveNonNumericChar("&field&")"
								'End if
							End if
						End If 
					Else
						field = "DATEDIFF(d,'"&value&"',"&field&")"
						value = 0
					End if
				End If
				If fieldType = "text" Or fieldType = "drop_down" Or fieldType = "long_text" Then
					If field = "salt" Then
						Call getconnectedJchemReg
						Set nRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT molid FROM "&regSaltsView&" WHERE cd_id="&SQLClean(value,"N","S")
						nRec.open strQuery,jchemRegConn,3,3
						If nRec.eof Then
							qStr = qStr & "1=2"
						Else
							valueList = "("
							Do While Not nRec.eof
								valueList = valueList & nRec("molid")
								nRec.moveNext
								If Not nRec.eof Then
									valueList = valueList &","
								End if
							Loop
							valueList = valueList & ")"
							qStr = qStr & "cd_id "&qualifier&" "&valueList 
						End If
						nRec.close
						Set nRec = nothing
					Else
						qStr = qStr &field & " " & qualifier & " " & value
						If value = "''" Then
							qStr = qStr & " OR " & field & " IS NULL"
						End If
						If field="reg_id" And qualifier="=" Then
							'two
							qStr = qStr &" OR "&field & " " & qualifier & " " &left(value,Len(value)-1)&"-"&padWithZeros(0,regBatchNumberLength)&"'"
						End if
					End if
				Else
					If InStr(field,"|")>-1 And fieldType<>"date" Then
						fs = Split(field,"|")
						qStr = qStr & " ("
						For j=0 To UBound(fs)
							qStr = qStr	& "dbo.RemoveNonNumericChar("&fs(j) & ") " & qualifier & " " & "dbo.RemoveNonNumericChar("&value&")" & " OR "
						Next
						qStr = qStr & "1=2)"
					else
						qStr = qStr & " " & field & " " & qualifier & " " & value
					End if
					If field="reg_id" And qualifier<>"in" Then
						qStr = qStr & " OR " &field & " " & qualifier & " " & left(value,Len(value)-1)&"-"&padWithZeros(0,regBatchNumberLength)&"'"
					End if
				End if
				lastGroupNumber = groupNumber
			Else
				contraction = SQLClean(request.Form("contraction_"&groupNumber&"_"&fieldNumber),"TP","S")
				field = SQLClean(request.Form("field_"&groupNumber&"_"&fieldNumber),"TP","S")
				qualifier = SQLClean(request.Form("qualifier_"&groupNumber&"_"&fieldNumber),"TP","S")
				value = SQLClean(MultiTrim(request.Form("value_"&groupNumber&"_"&fieldNumber)),"TP","S")
				If qualifier = "not_like" then
					qualifier = "not like"
				End if
				'int float date text long_text drop_down
				'lt lte gt gte eq neq like
				Select Case qualifier
					Case "eq"
						If field = "salt" Then
							qualifier = "in"
						else
							qualifier = "="
							If sqlLikeMode then
								qualifier = "LIKE"
							End if
						End if
					Case "neq"
						If field = "salt" Then
							qualifier = "not in"
						else
							If sqlLikeMode then
								qualifier = "NOT LIKE"
							Else
								qualifier = "<>"
							End if
						End if
				End select
				If fieldType = "text" Or fieldType = "drop_down" Or fieldType = "long_text" Then
					If field <> "salt" then
						value = "'"&value&"'"
					End if
				End If
				'If value = "''" Or value="" Then
				'	value = "null"
				'	fieldType = "text"
				'End If
				If (qualifier = "like" Or qualifier="not like") And value <> "null" Then
					value = "'%"&Mid(value,2,Len(value)-2)&"%'"
				End If
				If qualifier = "in" Then
					list = Split(Mid(value,2,Len(value)-2),",")
					value = "("
					for q = 0 To UBound(list)
						value = value & SQLClean(Trim(list(q)),"T","S")
						If q < UBound(list) Then
							value = value & ","
						end if
					Next
					value = value & ")"
				End if
				If fieldType = "int" Or fieldType = "float" Or fieldType = "actual_number" Or fieldType="date" Then
					Select Case qualifier
						Case "lt"
							qualifier = "<"
						Case "lte"
							qualifier = "<="
						Case "gt"
							qualifier = ">"
						Case "gte"
							qualifier = ">="
					End Select
					If fieldType <> "date" then
						If InStr(field,"|")=-1 then
							value = "dbo.RemoveNonNumericChar("&value&")"
							field = "dbo.RemoveNonNumericChar("&field&")"
						End if
					Else
						field = "DATEDIFF(d,'"&value&"',"&field&")"
						value = 0
					End if
				End If
				If fieldType = "text" Or fieldType = "drop_down" Or fieldType = "long_text" Then
					If field = "salt" Then
						Set nRec = server.CreateObject("ADODB.RecordSet")
						strQuery = "SELECT molid FROM "&regSaltsView&" WHERE cd_id="&SQLClean(value,"N","S")
						nRec.open strQuery,conn,3,3
						If nRec.eof Then
							qStr = qStr & " " & contraction & " " & "1=2"
						Else
							valueList = "("
							Do While Not nRec.eof
								valueList = valueList & nRec("molid")
								nRec.moveNext
								If Not nRec.eof Then
									valueList = valueList &","
								End if
							Loop
							valueList = valueList & ")"
							qStr = qStr & " " & contraction & " " & "cd_id "&qualifier&" "&valueList 
						End If
						nRec.close
						Set nRec = nothing
					Else
						qStr = qStr & " " & contraction & " " &field & " " & qualifier & " " & value
						If field="reg_id" And qualifier="=" Then
							qStr = qStr & " OR " & contraction & " " &field & " " & qualifier & " " &left(value,Len(value)-1)&"-"&padWithZeros(0,regBatchNumberLength)&"'"
						End if
					End if
				Else
					If InStr(field,"|")>-1 And fieldType<>"date" Then
						fs = Split(field,"|")
						qStr = qStr & " " & contraction & " ("
						For j=0 To UBound(fs)
							qStr = qStr	& "dbo.RemoveNonNumericChar("&fs(j) & ") " & qualifier & " " & "dbo.RemoveNonNumericChar("&value&")"& " OR "
						Next
						qStr = qStr & "1=2)"
					else
						qStr = qStr & " " & contraction & " " & field & " " & qualifier & " " & value
					End if
					If field="reg_id" Then
						qStr = qStr & " OR " & field & " " & qualifier & " " & left(value,Len(value)-1)&"-"&padWithZeros(0,regBatchNumberLength)&"'"
					End if
				End if


			End If
		Next
		qStr = qStr & "))"
		qStr = Replace(qStr,"dbo.RemoveNonNumericChar()","dbo.RemoveNonNumericChar(0)")
	%>
