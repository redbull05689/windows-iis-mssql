<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
class LD
	Private ld_array
	Private ld_isDict
	Private ld_isList
	Private ld_isString
	Private ld_isNumber
	Private ld_mode
	Private ld_keys
	Private ld_values

	Private Sub Class_Initialize()
		ld_mode = "L"
	End Sub

	Public function getMode()
		getMode = ld_mode
	End function

	Public Sub addKeys(inString)
		ld_mode = "D"
		a = Split(inString,",")
		ReDim ld_keys(0)
		ReDim preserve ld_keys(UBound(a))
		For i = 0 To UBound(a)
			ld_keys(i) = a(i)
		next
	End sub

	Public Sub addValues(inString)
		ld_mode = "D"
		addItems(inString)
	End Sub
	
	Public function addPair(keyName, newItem)
		ld_mode = "D"
		If Not IsEmpty(ld_keys) then
			If Not keyExists(keyName) Then
				ReDim preserve ld_keys(ubound(ld_keys)+1)
				ld_keys(UBound(ld_keys)) = keyName
				addItem(newItem)
			Else
				theIndex = getKeyIndex(keyName)
				addItemAtIndex theIndex,newItem
			End if
		Else
			ReDim ld_keys(0)
			ld_keys(UBound(ld_keys)) = keyName
			addItem(newItem)
		End If
	End function
	
	Private Sub clearFlags(index)
		ld_isDict(index) = False
		ld_isList(index) = False
		ld_isString(index) = False
		ld_isNumber(index) = False
	End sub

	Public property Let mode(theMode)
		ld_mode = theMode
	End property

	Public Sub addItems(itemList)
		a = Split(itemList,",")
		For Each item In a
			addItem(item)
		next
	End sub

	Private Sub addItemAtIndex(theIndex,newItem)
		clearFlags(theIndex)
		On Error Resume Next
		ld_array(theIndex) = newItem
		If Err.number = 0 Then
			'REG-19
			If IsNumeric(newItem) And instr(newItem,"(") = 0 And instr(newItem,",") = 0 Then
				ld_isNumber(theIndex) = True
			Else
				ld_isString(theIndex) = true
			End if
		Else
			Err.clear
			ld_t = newItem.mode
			If Err.number <> 0 Then
				ld_isDict(theIndex) = True
			Else
				ld_isList(theIndex) = True
			End If
			Set ld_array(theIndex) = newItem
		End If
		On Error goto 0
	End sub

	Public Sub addItem(newItem)
		If Not IsEmpty(ld_array) then
			ReDim preserve ld_array(ubound(ld_array)+1)
			ReDim preserve ld_isDict(ubound(ld_array)+1)
			ReDim preserve ld_isList(ubound(ld_array)+1)
			ReDim preserve ld_isString(ubound(ld_array)+1)
			ReDim preserve ld_isNumber(ubound(ld_array)+1)
		Else
			ReDim ld_array(0)
			ReDim ld_isDict(0)
			ReDim ld_isList(0)
			ReDim ld_isString(0)
			ReDim ld_isNumber(0)
		End If
		clearFlags(UBound(ld_array))
		On Error Resume Next
		ld_array(UBound(ld_array)) = newItem
		If Err.number = 0 Then
			'REG-19
			If IsNumeric(newItem) And instr(newItem,"(") = 0 And instr(newItem,",") = 0 Then
				ld_isNumber(UBound(ld_array)) = True
			Else
				ld_isString(UBound(ld_array)) = true
			End if
		Else
			Err.clear
			ld_t = newItem.mode
			If Err.number <> 0 Then
				ld_isDict(ubound(ld_array)) = True
			Else
				ld_isList(ubound(ld_array)) = True
			End If
			Set ld_array(ubound(ld_array)) = newItem
		End If
		On Error goto 0
	End sub

	Public Property Get getArray()
		getArray = ld_array
	End Property

	Public Property Get keys()
		keys = ld_keys
	End property

	Public Property Get count()
		If Not IsEmpty(ld_array) then
			count = ubound(ld_array)
		Else
			count = -1
		End if
	End property

	Public Property Get obType()
		obType = ld_mode
	End Property
	
	Public Function getItemType(index)
		If Not IsNumeric(index) then
			For i = 0 To UBound(ld_array)
				If ld_keys(i) = index then
					index = i
				End if
			next
		End if
		If ld_isDict(index) Then
			getItemType = "dict"
		End If
		If ld_isList(index) Then
			getItemType = "list"
		End If
		If ld_isNumber(index) Or ld_isString(index) Then
			getItemType = "data"
		End If
	End function

	Public Function inList(val)
		Dim i
		inList = False
		If IsArray(ld_array) then
			For i = 0 To UBound(ld_array)
				If ld_isNumber(i) Or ld_isString(i) Then
					If ld_array(i) = val then
						inList = True
					End if
				End if
			next
		End if
	End function

	Private Function getKeyIndex(key)
		Dim i
		getKeyIndex = -1
		If IsArray(ld_keys) then
			For i = 0 To UBound(ld_keys)
				If ld_keys(i) = key Then
					getKeyIndex = i
				End if
			next
		End if
	End function

	Public Function keyExists(key)
		Dim i
		keyExists = False
		If IsArray(ld_keys) then
			For i = 0 To UBound(ld_keys)
				If ld_keys(i) = key Then
					keyExists = True
				End if
			next
		End if
	End function

	Public Function getItem(index)
		Dim i
		If Not IsNumeric(index) then
			For i = 0 To UBound(ld_array)
				If ld_keys(i) = index then
					index = i
				End if
			next
		End If
		Set getItem = ld_array(index)
	End function

	Public Function hasKey(keyName)
		Dim i
		hasKey = False
		If IsArray(ld_array) then
			For i = 0 To UBound(ld_array)
				If ld_keys(i) = keyName then
					hasKey = true
				End if
			Next
		End if
	End function

	Public Function getData(ByVal index)
		Dim i
		If Not IsNumeric(index) then
			For i = 0 To UBound(ld_array)
				If ld_keys(i) = index then
					index = i
				End if
			next
		End If
		getData = ld_array(index)
	End function

	public Function getStructure(tabs)
		Dim i,j
		tabsStr = ""
		For j = 0 To tabs
			tabsStr = tabsStr & "&nbsp;&nbsp;"
		next
		tabsStr2 = ""
		For j = 0 To tabs -1
			tabsStr2 = tabsStr2 & "&nbsp;&nbsp;"
		next
		If ld_mode = "L" then
			str = "[<br>"
		End If
		If ld_mode = "D" then
			str = "{<br>"
		End If
		If IsArray(ld_array) then
			For i = 0 To UBound(ld_array)
				If ld_isDict(i) then
					If ld_mode = "L" then
						str = str & tabsStr & ld_array(i).getStructure(tabs+1)
					End If
					If ld_mode = "D" Then
						str = str & tabsStr & "'" & ld_keys(i) & "': " & ld_array(i).getStructure(tabs+1)
					End if
				End If
				If ld_isList(i) then
					If ld_mode = "L" then
						str = str & tabsStr &  ld_array(i).getStructure(tabs+1)
					End If
					If ld_mode = "D" Then
						str = str & tabsStr & "'" & ld_keys(i) & "': " & ld_array(i).getStructure(tabs+1)
					End if
				End If
				If ld_isString(i) Then
					If ld_mode = "L" then
						str = str & tabsStr & "'" & ld_array(i) & "'"
					End If
					If ld_mode = "D" Then
						str = str & tabsStr & "'" & ld_keys(i) & "': '" & ld_array(i) & "'"
					End if
				End If
				If ld_isNumber(i) Then
					If ld_mode = "L" then
						str = str & tabsStr & ld_array(i)
					End If
					If ld_mode = "D" Then
						str = str & tabsStr & "'" & ld_keys(i) & "': " & ld_array(i)
					End if
				End if
				If i < UBound(ld_array) Then
					str = str & ", <br>"
				End if
			Next
		End if
		If ld_mode = "L" then
			str = str & "<br>"&tabsStr2&"]"
		End If
		If ld_mode = "D" then
			str = str & "<br>"&tabsStr2&"}"
		End If
		getStructure = str
	End function

	Public Sub printStructure()
		response.write(getStructure(0))
	End sub

	Public function serialize(sType)
		Dim i
		If ld_mode = "L" then
			str = "["
		End If
		If ld_mode = "D" then
			str = "{"
		End If
		If IsArray(ld_array) then
			For i = 0 To UBound(ld_array)
				If IsNull(ld_array(i)) then
					ld_array(i) = ""
				End if
				If ld_isDict(i) then
					If ld_mode = "L" then
						str = str & ld_array(i).serialize(sType)
					End If
					If ld_mode = "D" Then
						If sType = "js" then
							str = str & """" & ld_keys(i) & """: " & ld_array(i).serialize(sType)
						ElseIf sType = "python" then
							str = str & "'" & ld_keys(i) & "': " & ld_array(i).serialize(sType)
						End if
					End if
				End If
				If ld_isList(i) then
					If ld_mode = "L" then
						str = str & ld_array(i).serialize(sType)
					End If
					If ld_mode = "D" Then
						If sType = "js" then
							str = str & """" & ld_keys(i) & """: " & ld_array(i).serialize(sType)
						ElseIf sType = "python" Then
							str = str & "'" & ld_keys(i) & "': " & ld_array(i).serialize(sType)
						End if
					End if
				End If
				If ld_isString(i) Then
					If ld_mode = "L" then
						If sType = "js" then
							str = str & """" & Replace(Replace(Replace(ld_array(i),vbcrlf,"\n"),vbcr,"\n"),vblf,"\n") & """"
						ElseIf sType = "python" Then
							str = str & "'" & Replace(Replace(Replace(Replace(ld_array(i),"'","\'"),vbcrlf,"\n"),vbcr,"\n"),vblf,"\n") & "'"
						End if
					End If
					If ld_mode = "D" Then
						If sType = "js" then
							str = str & """" & ld_keys(i) & """: """ & Replace(Replace(Replace(ld_array(i),vbcrlf,"\n"),vbcr,"\n"),vblf,"\n") & """"
						ElseIf sType = "python" Then
							str = str & "'" & ld_keys(i) & "': '" & Replace(Replace(Replace(Replace(ld_array(i),"'","\'"),vbcrlf,"\n"),vbcr,"\n"),vblf,"\n") & "'"
						End if
					End if
				End If
				If ld_isNumber(i) Then
					If ld_mode = "L" then
						str = str & ld_array(i)
					End If
					If ld_mode = "D" Then
						If sType = "js" then
							str = str & """" & ld_keys(i) & """: " & ld_array(i)
						ElseIf sType = "python" Then
							str = str & "'" & ld_keys(i) & "': " & ld_array(i)
						End if
					End if
				End if
				If i < UBound(ld_array) Then
					str = str & ", "
				End if
			Next
		End if
		If ld_mode = "L" then
			str = str & "]"
		End If
		If ld_mode = "D" then
			str = str & "}"
		End if
		serialize = Replace(str,vbcrlf,"\n")
	End function

end class
%>

<%
'Set test = new LD
'test.addItems("6,7,8,9")
'test.mode = "L"
'response.write(test.serialize("js"))


'Set test3 = new LD
'test3.addPair "pi",3.1415
'response.write(test3.serialize("js"))
'test.addItem(test3)

'Set test2 = new LD
'test2.addKeys("one,two,three,four")
'test2.addValues("1,2,3,4")
'test2.addPair "five",test

'response.write(test2.serialize("js"))

%>