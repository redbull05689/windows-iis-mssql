<%
function removeDuplicates(inString)
	arr = split(inString,",")

	Set D = Server.CreateObject("Scripting.Dictionary")
	For Each elem In arr
	    If Not D.Exists(elem) Then D.Add elem, elem
	Next

	rStr = ""
	counter = 0
	For Each elem in D.Items
		counter = counter +1
		rStr = rStr & elem & ","
	Next
	If counter > 0 Then
		rStr = Mid(rStr,1,Len(rStr)-1)
	End If
	removeDuplicates = rStr
end function
%>