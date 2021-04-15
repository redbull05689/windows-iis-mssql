<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function returnImageFile(filepath, filename, defaultPath, defaultFile)
	itWorked = False
	returnImageFile = itWorked
	theFile = filepath & filename

	' Try to load and return the image data for the product
	Set fs=Server.CreateObject("Scripting.FileSystemObject")
	if fs.FileExists(theFile) Then
		Set adoStream = CreateObject("ADODB.Stream")
		If Err.number = 0 Then
			adoStream.Open()
			If Err.number = 0 Then
				adoStream.Type = 1
				If Err.number = 0 Then
					On Error Resume Next
					adoStream.LoadFromFile(theFile)
					If Err.number = 0 Then
						readBytes = adoStream.Read()
						if Not IsNull(readBytes) Then
							If Ubound(readBytes) > 0 Then
								itWorked = True
								returnImageFile = itWorked
								Response.BinaryWrite readBytes
								response.end()
							End If 
						End if
					End If
					On Error GoTo 0
				End If 
			End If
		End If
		adoStream.Close
		Set adoStream = Nothing
	End If
	
	' if it didn't work for some reason, return a blank image
	If Not itWorked And filename <> defaultFile And defaultFile <> "return-error" Then
		Call returnImageFile(defaultPath, defaultFile, defaultPath, defaultFile)
	End If
End Function
%>