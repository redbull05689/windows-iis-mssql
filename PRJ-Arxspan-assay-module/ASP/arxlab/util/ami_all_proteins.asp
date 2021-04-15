<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/fnc_sendProteinToSeurat.asp" -->
<%
if session("userId") = "2" Or session("email")="support@arxspan.com" And 1=2 then

	call getconnectedAdm
	call getconnectedAdm
	Call getConnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery  = "SELECT * FROM arx_reg_base_molecules_am WHERE groupId=24"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		sendProteinToSeurat(rec("cd_id"))
		rec.movenext
	Loop
	call disconnect	
	call disconnectadm
	Call disconnectJchemReg
end If
%>