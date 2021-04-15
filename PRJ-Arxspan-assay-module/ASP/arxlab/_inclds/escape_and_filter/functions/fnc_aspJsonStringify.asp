<%
Function aspJsonStringify(theStr)
	If Len(theStr) > 0 Then
		theIncomingStr = theStr
		theIncomingStr = JSON.stringify(theIncomingStr)
		theIncomingStr = mid(theIncomingStr, 2, Len(theIncomingStr)-2)
		aspJsonStringify = theIncomingStr
	Else

	aspJsonStringify = theStr
	End If
End Function
%>