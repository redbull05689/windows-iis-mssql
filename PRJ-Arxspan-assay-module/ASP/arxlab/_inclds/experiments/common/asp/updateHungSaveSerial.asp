<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
	insertStmt = "UPDATE serialsAck SET revisionNumber="&revisionNumber&" WHERE SERIAL="&cleanSerial		
	Call getconnectedadm
	connAdm.execute(insertStmt)
	Call disconnectadm
%>
