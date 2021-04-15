<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function ipsFromRange(ipRange)
	Dim i,j,k,l
	Set regEx = New RegExp
	regEx.Pattern = "[^\*\.\-/,0-9]"
	regEx.IgnoreCase = True
	regEx.Global = True
	ipRange = regEx.Replace(ipRange,"")

	ipString = ""
	arr1 = Split(ipRange,",")
	For i = 0 To UBound(arr1)
		thisVal = Trim(arr1(i))
		octets = Split(thisVal,".")
		Do While UBound(octets) < 3 
			thisVal = thisVal & ".*"
			octets = Split(thisVal,".")
		loop
		If InStr(thisVal,"-")>0 Or InStr(thisVal,"/")>0 Or InStr(thisVal,"*")>0 then
			theRange = ""
			For j = 0 To 3
				If octets(j) = "*" Or octets(j) = "" Then
					theRange = "0-255"
				End If
				If InStr(octets(j),"/")>0 Then
					theRange = Replace(octets(j),"/","-")
				End If
				If InStr(octets(j),"-")>0 Then
					theRange = octets(j)
				End If
				If theRange <> "" then
					For k = Int(Split(theRange,"-")(0)) To Int(Split(theRange,"-")(1))
						thisIp = ""
						For l = 0 To 3
							If l <> j Then
								ipString = ipString & octets(l)
							Else
								ipString = ipString & k
							End If
							If l <> 3 Then
								ipString = ipString & "."
							End if
						Next
						ipString = ipString & thisIp & ","
					Next
					Exit for
				End if
			next
		Else
			ipString = ipString & thisVal & ","
		End if
	Next
	If ipString <> "" Then
		ipString = Mid(ipString,1,Len(ipString)-1)
	End If
	If InStr(ipString,"-")>0 Or InStr(ipString,"*")>0 Then
		arr = Split(ipString,",")
		For i = 0 To UBound(arr)
			If InStr(arr(i),"-")>0 Or InStr(arr(i),"*")>0 Then
				ipString = Replace(ipString,arr(i),"")
				ipString = Replace(ipString,",,",",")
				ipString = ipString & "," & ipsFromRange(arr(i))
			End if
		Next
		ipsFromRange = Mid(ipString,2,Len(ipString))
	Else
		ipsFromRange = ipString
	End if
end function
%>