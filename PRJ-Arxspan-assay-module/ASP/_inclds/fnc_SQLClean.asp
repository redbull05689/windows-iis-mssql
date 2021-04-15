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
		   '  encapsulate with ''
			  SQLClean = "'" & CleanInput &"'"

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
		if isNumeric(CleanInput) then
			SQLClean = CleanInput
		'If its not a number show error
		else
			SQLClean = 0
			Response.write "<font color=""#FF0000"">ERROR:</font> Invalid number<br>"
		End if
  		'This is a Date Remove ' Do not encapsulate with ' or # Even if requested.		 
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


%>