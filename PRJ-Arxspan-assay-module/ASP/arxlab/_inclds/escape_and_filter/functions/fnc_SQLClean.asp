<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'Function to clean querystring variables
Function QSClean(CleanInput)

	if Instr(CleanInput,";")>0 then
		dim realParam
		realParam=split(CleanInput,";")

		CleanInput=realParam(0)

		'	response.write(realParam(0))
		'	response.write(CleanInput)
	 End If

   If Isnull(CleanInput) then
		CleanInput=""
	 else
		CleanInput=trim(CleanInput)
   End if

		QSClean = CleanInput
End Function


Function SQLClean(ByVal CleanInput,TypeInput,TypeOutput)

	 'Added on 05-19-08 to remove ';' from the input string
	 
	 'if Instr(CleanInput,";")>0 then
		'dim realParam
		'realParam=split(CleanInput,";")

		'CleanInput=realParam(0)

		'	response.write(realParam(0))
		'	response.write(CleanInput)
	 'End If

   If Isnull(CleanInput) then
   CleanInput=""
   End if
	
   ' Procedure Name:     
   ' Author: Roberto Lloveras   
   ' Date Created:     
   '
   ' Notes   
   ' *****   
   '  
   '    
   ' Parameters   
   ' **********   
   ' CleanInput  : The Text,date,Number you would like to clean up 
   '    
   ' TypeInput : D ( For Date ), N For Number , T For Text
   '
   'TypeOutput  : S for Single Quote or N For Pound Sign 
   '
   'Example
   'SQLClean ("Text's","T","S")
   ' Output:
   '
   ' 'Text''s'
   '
   'SQLClean ("8/10/2002","D","N")
   ' Output:
   '
   ' #8/10/2002#
   '
   ' Revision History   
   ' ****************   
   ' Change date:   
   ' Change by:   
   ' Change notes:
   'CleanInput,TypeInput,TypeOutput
   
   Select Case TypeInput
   
	   Case "T"
	   
	   'This is text Replace ' With ''
		If CleanInput="''" Then
			SQLClean="''"
		Else
		   CleanInput = Replace (CleanInput,"'","''")
			Set RegEx = New regexp
			RegEx.Pattern = "\\\n"
			RegEx.Global = True
			RegEx.IgnoreCase = True
			CleanInput = RegEx.Replace(CleanInput,"\ "&vbcrlf)
			Set RegEx = nothing
		   '  encapsulate with ''
			  SQLClean = "'" & CleanInput &"'"

		End if
		
		
		Case "JSON"
		'This is for JSON - it doesn't encapsulate in single quotes
			If CleanInput="''" Then
				SQLClean="''"
			Else
		   CleanInput = Replace (CleanInput,"'","''")
				Set RegEx = New regexp
				RegEx.Pattern = "\\\n"
				RegEx.Global = True
				RegEx.IgnoreCase = True
				CleanInput = RegEx.Replace(CleanInput,"\ "&vbcrlf)
				Set RegEx = nothing
			   '  encapsulate with ''
				  SQLClean = CleanInput
			End if
			
			If TypeOutput = "XML" Then
				CleanInput = Replace(CleanInput,"&","&amp;")
				CleanInput = Replace(CleanInput,"""","&quot;")
				CleanInput = Replace(CleanInput,">","&gt;")
				CleanInput = Replace(CleanInput,"<","&lt;")
				CleanInput = Replace(CleanInput,"%","&#37;")
				CleanInput = removeInvalidXMLChars(CleanInput)
				SQLClean = CleanInput
			End If

		Case "JS"
			'This is for JavaScript - Mostly for OnClicks
			CleanInput = Replace(CleanInput, "'", "\x27")
			CleanInput = Replace(CleanInput, """", "\x22")
			
			Set RegEx = New regexp
			RegEx.Pattern = "\\\n"
			RegEx.Global = True
			RegEx.IgnoreCase = True
			CleanInput = RegEx.Replace(CleanInput,"\ "&vbcrlf)
			Set RegEx = nothing
			
			SQLClean = CleanInput
		

	   Case "T-PROC"
		   'This is text Replace ' With ''
			If CleanInput="''" Then
				SQLClean="''"
			Else
				Set RegEx = New regexp
				RegEx.Pattern = "\\\n"
				RegEx.Global = True
				RegEx.IgnoreCase = True
				CleanInput = RegEx.Replace(CleanInput,"\ "&vbcrlf)
				Set RegEx = nothing
			   '  encapsulate with ''
				  SQLClean = CleanInput
			End if
			
			If TypeOutput = "XML" Then
				CleanInput = Replace(CleanInput,"&","&amp;")
				CleanInput = Replace(CleanInput,"""","&quot;")
				CleanInput = Replace(CleanInput,">","&gt;")
				CleanInput = Replace(CleanInput,"<","&lt;")
				CleanInput = Replace(CleanInput,"%","&#37;")
				CleanInput = removeInvalidXMLChars(CleanInput)
				SQLClean = CleanInput
			End If

	   Case "TP"
	   
	   'This is text Replace ' With ''
		If CleanInput="''" Then
			SQLClean="''"
		Else
		   CleanInput = Replace (CleanInput,"'","''")
		   '  encapsulate with ''
			  SQLClean = CleanInput
		End if

	   Case "L"
	   
	   'This is text Replace ' With ''
		If CleanInput="''" Then
			SQLClean="''"
		Else
		   CleanInput = Replace (CleanInput,"'","''")
		   '  encapsulate with ''
			  SQLClean = "'%" & UCase(CleanInput) &"%'"
		End if

	   Case "LS"
	   
	   'This is text Replace ' With ''
		If CleanInput="''" Then
			SQLClean="''"
		Else
		   CleanInput = Replace (CleanInput,"'","''")
		   '  encapsulate with ''
			  SQLClean = "'% " & CleanInput &" %'"

		End if

	   Case "PW"
	   'pw_stuff
	   'This is text Replace ' With ''
		If CleanInput="''" Then
			SQLClean="''"
		Else
			CleanInput = Replace (CleanInput,"'","''")
			'  encapsulate with ''
				SQLClean = "HASHBYTES('SHA1','" & CleanInput &"')"
		End if
	   
	   Case "D"
	   'This is a Date Remove '  And encapsulate with '' OR ## depending on the TypeOutput
	   
	   'Remove any '
	   If CleanInput="''" Then
			SQLClean="''"
		Else
		   CleanInput = Replace (CleanInput,"'","")
		  
			If TypeOutput = "S" Then
				SQLClean = "'" & CleanInput &"'"
			Elseif  TypeOutput = "N" Then
				'use # if using access database
				'SQLClean = "#" & CleanInput &"#"
				SQLClean = CleanInput
			Else
				SQLClean = ""
		   End if
	  End if
	   
		
	
	Case "N"	   
		On Error Resume Next
		'Lets make sure its a number
		If TypeOutput="N" And (IsNull(CleanInput) Or cleanInput="") Then
			SQLClean = NULL
		Else
			If IsNull(CleanInput) Or cleanInput="" Then
				cleanInput = 0
			End if
			if isNumeric(CStr(CleanInput)) then
				SQLClean = CleanInput
			'If its not a number show error
			else
				SQLClean = NULL
				'Response.write "<font color=""#FF0000"">ERROR:</font> Invalid number "&cleanInput&"<br>"
			End if
		End If
  		'This is a Date Remove ' Do not encapsulate with ' or # Even if requested.	

	Case "CSV"
		' This will escape field values for a CSV file, but only if needed
		Set RegEx = New regexp
		RegEx.Pattern = """|,|"&vbcrlf
		RegEx.Global = True
		RegEx.IgnoreCase = True
		NeedsQuotes = RegEx.Test(CleanInput)
		if NeedsQuotes = True then
			Set RegEx2 = New regexp
			RegEx2.Pattern = """"
			RegEx2.Global = True
			RegEx2.IgnoreCase = True
			CleanInput = RegEx2.Replace(CleanInput, """""")
			
			CleanInput = """" & CleanInput & """"

			Set RegEx2 = nothing
		end if 
		Set RegEx = nothing
		CleanInput = Replace(CleanInput, CHR(13), "") ' remove carriage returns
		CleanInput = Replace(CleanInput, CHR(10), "") ' remove new lines
		SQLClean = CleanInput
   	End Select
End Function 

Function AllowOnlyChar(StringToClean, AllowedCharacters)
	Dim i, j, tmp, strOutput
	strOutput = ""
	for j = 1 to len(StringToClean)
		tmp = Mid(StringToClean, j, 1)

			if instr(AllowedCharacters,tmp)>0 then
			tmp = tmp
			else
			tmp = ""
			End if
			
			
		strOutput = strOutput & tmp
	next
	AllowOnlyChar = strOutput
End Function


function removeInvalidXMLChars(dirtyString)
    'From xml spec valid chars: 
    '#x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]     
    'any Unicode character, excluding the surrogate blocks, FFFE, and FFFF. 

	dim oRegEx
	Set oRegEx = New RegExp
	oRegEx.Pattern = "[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u10000-\u10FFFF]"
	oRegEx.Global = true
	removeInvalidXMLChars = oRegEx.replace( dirtyString, "")

end Function


%>