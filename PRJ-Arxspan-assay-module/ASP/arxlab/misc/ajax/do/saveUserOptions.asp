<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
Response.CodePage = 65001

Call getconnectedadm

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT options from users WHERE id="&SQLClean(session("userId"),"N","S")
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	theOptions = "{}"
	If Not IsNull(rec("options")) Then
		If rec("options") <> "" Then
			theOptions = rec("options")
		End if
	End if
	Set thePairs = JSON.parse(join(array(request.Form("thePairs"))))
	Set userOptions = JSON.parse(theOptions)
	For Each key In thePairs.keys()
		userOptions.Set thePairs.Get(key).Get("theKey"),thePairs.Get(key).Get("theVal")
	next	
	strQuery = "UPDATE users SET options="&SQLClean(JSON.stringify(userOptions),"T","S")&" WHERE id="&SQLClean(session("userId"),"N","S")
	connAdm.execute(strQuery)
	session("userOptions") = JSON.stringify(userOptions)
End if

Call disconnectadm()
%>