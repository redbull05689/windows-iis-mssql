<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<%
searchKey = request.querystring("searchKey")
cdId = request.querystring("cdId")
value = request.querystring("value")
If searchKey <> "" then
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM searchKeys WHERE searchKey="&SQLClean(searchKey,"T","S")& " AND userId="&SQLClean(session("userId"),"N","S")
	rec.open strQuery,jchemRegConn,3,3
	If Not rec.eof Then
		strQuery = "DELETE FROM searchKeyCdIds WHERE searchKey="&SQLClean(searchKey,"T","S")&" AND cdId="&SQLClean(cdId,"N","S")
		jchemRegConn.execute(strQuery)
		If value = "1" Then
			strQuery = "INSERT INTO searchKeyCdIds(searchKey,cdId) values("&SQLClean(searchKey,"T","S")&","&SQLClean(cdId,"N","S")&")"
			jChemRegConn.execute(strQuery)
		End if
	End if
	Call disconnectJchemReg
End if
%>