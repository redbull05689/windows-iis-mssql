<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp" -->
<%
Call getconnectedJchemReg
Set tRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM importProgress ORDER BY id DESC"
tRec.open strQuery,jchemRegConn,3,3
If Not tRec.eof Then
	response.write(tRec("percentComplete"))
end if
%>