<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
'this feature was never really used.  The idea was to send warning messages to users when we were going to do a push that they should save their data and log out
	On Error Resume next
	strQuery = "SELECT * FROM maintenanceWindows WHERE DATEDIFF(minute,GETUTCDATE(),startTime)<20 and DATEDIFF(minute,GETUTCDATE(),endTime)>0"
	Set idmwRec = server.CreateObject("ADODB.RecordSet")
	idmwRec.open strQuery,conn,3,3
	If idmwRec.eof Then
		response.write("")
	Else
		strQuery = "SELECT * FROM maintenanceWindowWarnings WHERE userId="&SQLClean(session("userId"),"N","S") & " AND mWindowId=" & SQLClean(idmwRec("id"),"N","S")
		Set idmwRec2 = server.CreateObject("ADODB.RecordSet")
		idmwRec2.open strQuery,conn,3,3
		If idmwRec2.eof then
			strQuery = "INSERT into maintenanceWindowWarnings(userId,mWindowId) values("&SQLClean(session("userId"),"N","S")&","&SQLClean(idmwRec("id"),"N","S")&")"
			Call getconnectedadm
			connadm.execute(strQuery)
			warning = "warning### The ELN will be going down for planned maintenance at " & idmwRec("startTime") & " EST(GMT -5:00) and returning at "& idmwRec("endTime") &" EST(GMT -5:00). Please make sure to save your work before this time."
			response.write(warning)
		Else
			response.write("")
		End if
	End if
%>