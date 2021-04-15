<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%If request.servervariables("REMOTE_ADDR") <> "8.20.189.21" or request.servervariables("REMOTE_ADDR") <> "8.20.189.22" then
	response.end
End if%>
<%isApiPage=True%>
<% Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<%
If request.querystring("override") = "BROAD" Then
	session("overrideDB")="BROAD"
End if
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DATEDIFF(second,lastActivityTime,GETUTCDATE()) as inactivityTime,sessionTimeoutMinutes from usersView WHERE sessionTimeout=1 AND id="&SQLClean(request.querystring("userId"),"N","S")
rec.open strQuery,conn,0,-1
If rec.eof then
	response.write("false")
else
	If IsNull(rec("inactivityTime")) Then
		response.write("false")
	Else
		If rec("inactivityTime")/60 > rec("sessionTimeoutMinutes") Then
			response.write("true")
		Else
			response.write("false")
		End if
	End if
End if
rec.close
Set rec = nothing
call disconnect
%>