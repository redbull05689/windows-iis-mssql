<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
resp = "[]"
casName = request.form("casName")

If casName <> "" Then
	strQuery = "select top 25 traditional_name, cd_id, cas, cd_molweight from casNumberLookup where "
	strQuery = strQuery & "CONTAINS(traditional_name, '""" & casName & "*""') OR "
	strQuery = strQuery & "CONTAINS(traditional_name_backward, '""" & StrReverse(casName) & "*""') "
	strQuery = strQuery & "ORDER BY nameLength"

	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery, casDbConn, adOpenForwardOnly, adLockReadOnly
	
	If rec.eof Then
		rec.close
		strQuery = "select top 25 traditional_name, cd_id, cas, cd_molweight from casNumberLookup where traditional_name like '%" & casName & "%' ORDER BY nameLength"
		rec.open strQuery, casDbConn, adOpenForwardOnly, adLockReadOnly
	End If
	
	Do While Not rec.eof
		If resp = "[]" Then
			resp = "["
		Else
			resp = resp & ","
		End If
		
		resp = resp & "{""traditional_name"":"""&rec("traditional_name")&""",""cd_molweight"":"""&rec("cd_molweight")&""",""cas"":"""&rec("cas")&""",""cd_id"":"""&rec("cd_id")&"""}"
		rec.movenext
	Loop

	If resp <> "[]" Then
		resp = resp & "]"
	End If

	rec.close
	Set rec = Nothing
	disconnectCasDb
End If

response.write resp
%>