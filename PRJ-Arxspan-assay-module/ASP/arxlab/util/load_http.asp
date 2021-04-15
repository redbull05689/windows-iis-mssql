<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scriptTimeout = 640%>
<%=response.buffer = false%>

<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
if session("email")="support@arxspan.com" then

	call getconnectedAdm

	intervalSeconds = 30
	numSockets = 5000
	hostAddress = "dev.arxspan.com"
	hostPort = 5002
	numLoops = 5

	Dim conns()
	ReDim conns(numSockets*(numLoops+1))

	socketCount = 0
	counter = 0
    Do While True And counter < numLoops
		counter = counter + 1
		For i=1 To numSockets
			set conns((counter*i)+i) = server.Createobject("MSXML2.ServerXMLHTTP")
			conns((counter*i)+i).Open "POST","http://"&hostAddress&":"&hostPort,True
			conns((counter*i)+i).send "hello"
			conns((counter*i)+i).waitForResponse(60)
			Set conns((counter*i)+i) = Nothing
		Next
		socketCount = socketCount + numSockets
		response.write(counter & " "&socketCount&"<br>")

		strQuery = "WAITFOR DELAY '00:00:" & right(clng(intervalSeconds),2) & "'" 
	    connAdm.Execute strQuery,,129

	Loop
	
	Call disconnectadm
end If
%>