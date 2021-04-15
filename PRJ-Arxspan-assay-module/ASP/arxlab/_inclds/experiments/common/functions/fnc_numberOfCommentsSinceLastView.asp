<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<%
'return the number of comments added by other users to the specified experiment since the user last viewed the experiment
set ncRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT COUNT(id) as numComments FROM commentNotifications WHERE userId="&SQLClean(session("userId"),"N","S")& " AND experimentType="&SQLClean(request.querystring("experimentType"),"T","S") & " AND experimentId="&SQLClean(request.querystring("experimentId"),"T","S")  & " AND (dismissed=0 or dismissed is null) and commenterId <> "&SQLClean(session("userId"),"N","S")
ncRec.CursorLocation = adUseClient
ncRec.open strQuery,conn,adOpenStatic,adLockReadOnly,adCmdText
If ncRec("numComments") <> 0 Then
	'the number of records is equal to the number of comments
	response.write(ncRec("numComments"))
End If
ncRec.close
Set ncRec = Nothing
%>