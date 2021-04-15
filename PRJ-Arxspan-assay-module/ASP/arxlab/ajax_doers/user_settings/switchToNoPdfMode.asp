<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
'disables pdf viewing.  used when a pre 8 version of acrobat is detected
Do While session("noPdf") <> true
	session("noPdf") = true
	session.Save()
Loop
%>