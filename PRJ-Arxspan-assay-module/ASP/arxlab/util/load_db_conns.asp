<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scriptTimeout = 640%>
<%=response.buffer = false%>

<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
if session("email")="support@arxspan.com" then

	call getconnectedAdm

	intervalSeconds = 30
	numConns = 20000
	numLoops = 5

	Dim conns()
	ReDim conns(numConns*(numLoops+1))

	socketCount = 0
	counter = 0
    Do While True And counter < numLoops
		counter = counter + 1
		For i=1 To numConns
			connStr = "Provider=sqloledb;Data Source=8.20.189.26;Initial Catalog=OAUTH;User Id=oauth_admin;Password=jtest232323;Pooling=False;WSID="&((counter*i)+i)
			Set conns((counter*i)+i) = Server.CreateObject("ADODB.CONNECTION")
			conns((counter*i)+i).Open connStr
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM [User]"
			rec.open strQuery,conns((counter*i)+i),3,3
			rec.close
			Set rec = Nothing
			conns((counter*i)+i).close
			Set conns((counter*i)+i) = nothing
		Next
		socketCount = socketCount + numConns
		response.write(counter & " "&socketCount&"<br>")

		strQuery = "WAITFOR DELAY '00:00:" & right(clng(intervalSeconds),2) & "'" 
	    connAdm.Execute strQuery,,129

	Loop
	
	Call disconnectadm
end If
%>