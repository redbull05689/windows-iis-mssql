<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage=true%>
<% Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<%
If request.querystring("override") = "BROAD" Then
	session("overrideDB")="BROAD"
End if
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
usersTable = getDefaultSingleAppConfigSetting("usersTable")
call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DATEDIFF(second,lastActivityTime,GETUTCDATE()) as inactivityTime from "&usersTable&" WHERE id="&SQLClean(request.querystring("userId"),"N","S")
rec.open strQuery,conn,0,-1
If IsNull(rec("inactivityTime")) Then
	response.write("0")
else
	response.write(rec("inactivityTime"))
End if
rec.close
Set rec = nothing
call disconnect
%>