<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function ConvertUTCToLocal(utcTime)
	If utcTime & "" = "" Then
		ConvertUTCToLocal = ""
	Else
		Dim myObj, dateObj
		dateObj = CDate(utcTime)
		Set myObj = CreateObject("WbemScripting.SWbemDateTime")
		myObj.Year = Year(dateObj)
		myObj.Month = Month(dateObj)
		myObj.Day = Day(dateObj)
		myObj.Hours = Hour(dateObj)
		myObj.Minutes = Minute(dateObj)
		myObj.Seconds = Second(dateObj)
		ConvertUTCToLocal = myObj.GetVarDate(True)
	End If
End Function
%>