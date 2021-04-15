<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
if session("canEditKeywords") or session("role") = "Admin" Then
	companyId = SQLClean(session("companyId"),"N","S")
	groupId = SQLClean(session("groupId"),"T","S")
	displayText = SQLClean("#" & request.Form("keywordValue"),"T","S")
	disabled = 0
	userId = SQLClean(session("userId"),"N","S")

	errorString = ""

	Call getConnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM keywords WHERE displayText=" & SQLClean(request.Form("keywordValue"),"T","S") & " AND companyId=" & SQLClean(session("companyId"),"N","S")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		errorString = "This keyword already exists."
	End If


	If errorString = "" Then
		Call getconnectedAdm
		strQuery = "INSERT into keywords(companyId,groupId,displayText,disabled,dateAdded,addedByUserId) values("&_
				companyId & "," &_
				groupId & "," &_
				displayText & "," &_
				disabled & "," &_
				"GETDATE()" & "," &_
				userId & ")"
		connAdm.execute(strQuery)

		Set checkRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT TOP 1 * FROM keywords WHERE companyId="&SQLClean(session("companyId"),"N","S")&" ORDER BY id DESC"
		checkRec.open strQuery,conn,3,3
		Do While Not checkRec.eof
			response.write checkRec("id")
			checkRec.movenext
		loop

		Call disconnectAdm
	ElseIf errorString = "This keyword already exists." Then
		response.write "duplicate"
	End If
	Call disconnect
End if
%>