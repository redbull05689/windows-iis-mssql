<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%'The issue was that the month has to be set after the day.  Something to do with the date object being initialized as the current date%>
<script type="text/javascript">
d = new Date();
d.setUTCFullYear(2013);
d.setUTCMonth(2);
d.setUTCDate(25);
d.setUTCHours(12);
d.setUTCMinutes(0);
d.setUTCSeconds(0);
document.write(d.toString('m/dd/yyyy hh:MM:ss TT'));
</script>
<script type="text/javascript">
document.write('test');
</script>
<%
For i = 2010 To 2020
	For j = 0 To 11
		Select Case j
			Case 0
				theMonth = "Jan"
			Case 1
				theMonth = "Feb"
			Case 2
				theMonth = "Mar"
			Case 3
				theMonth = "Apr"
			Case 4
				theMonth = "May"
			Case 5
				theMonth = "Jun"
			Case 6
				theMonth = "July"
			Case 7
				theMonth = "Aug"
			Case 8
				theMonth = "Sep"
			Case 9
				theMonth = "Oct"
			Case 10
				theMonth = "Nov"
			Case 11
				theMonth = "Dec"
		End Select
		response.write("<h1>"&theMonth&" "&i&"</h1>")
		For k = 1 To 5
			myStr = "<script type=""text/javascript"">"
			myStr = myStr & "date = new Date();"
			myStr = myStr & "date.setUTCFullYear("&i&");"
			myStr = myStr & "date.setUTCDate("&k&");"
			myStr = myStr & "date.setUTCHours(12);"
			myStr = myStr & "date.setUTCMinutes(0);"
			myStr = myStr & "date.setUTCSeconds(0);"
			myStr = myStr & "date.setMonth("&j&");"
			myStr = myStr & "document.write(date.toString('m/dd/yyyy hh:MM:ss TT')+'<br/>');"
			myStr = myStr & "</script>"
			response.write(myStr)
		next
	next
next
%>