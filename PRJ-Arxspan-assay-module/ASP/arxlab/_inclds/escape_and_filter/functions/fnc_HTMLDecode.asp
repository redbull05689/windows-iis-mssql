<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function HTMLDecode(sText)
    Dim I
		if isnull(sText) then
			sText = ""
		end if
    sText = Replace(sText, "&quot;", Chr(34))
    sText = Replace(sText, "&lt;"  , Chr(60))
    sText = Replace(sText, "&gt;"  , Chr(62))
    sText = Replace(sText, "&amp;" , Chr(38))
    sText = Replace(sText, "&nbsp;", Chr(32))
    For I = 1 to 255
        sText = Replace(sText, "&#" & I & ";", Chr(I))
    Next
    HTMLDecode = sText
End Function


Function HTMLDecodeUnicode(sText)
    Dim I
    sText = HTMLDecode(sText)
    
    For I = 1 to 65535
        sText = Replace(sText, "&#" & I & ";", ChrW(I))
    Next
    HTMLDecodeUnicode = sText
End Function

Function HTMLDecodeUnicodeRegex(sText)
    if isnull(sText) then
        sText = ""
    end if
    sText = Replace(sText, "&quot;", "\""")
    sText = Replace(sText, "&lt;"  , Chr(60))
    sText = Replace(sText, "&gt;"  , Chr(62))
    sText = Replace(sText, "&amp;" , Chr(38))
    sText = Replace(sText, "&nbsp;", Chr(32))

    Set regEx= New RegExp

    With regEx
     .Pattern = "&#(\d+);" 'Match html unicode escapes
     .Global = True
    End With

    Set matches = regEx.Execute(sText)

    'Iterate over matches
    For Each match in matches
        'For each unicode match, replace the whole match, with the ChrW of the digits.

        sText = Replace(sText, match.Value, ChrW(match.SubMatches(0)))
    Next

    HTMLDecodeUnicodeRegex = sText


End Function

' This function takes a passed in regularExpression to determine whether the passed in text matches
' then calls to HTMLDecodeUnicodeRegex
Function CleanAndDecodeData(regularExpression, text, typeInput, typeOutput)
	
	dim match    
    CleanAndDecodeData = ""    	
	
	If not IsNull(text)  Then
		
		set match = regularExpression.Execute(text)

		if match.count > 0 then
			CleanAndDecodeData = HTMLDecodeUnicodeRegex(text)
			CleanAndDecodeData = SQLClean(CleanAndDecodeData, typeInput, TypeOutput)
		else
			CleanAndDecodeData = SQLClean(text, typeInput, TypeOutput)
		end If
	End If

End Function


%>