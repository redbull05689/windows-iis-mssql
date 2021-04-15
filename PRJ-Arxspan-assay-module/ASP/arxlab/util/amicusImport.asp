<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
If session("email") = "dan.robinhold@arxspan.com" And 1=2 Then
	Call getConnectedJchemReg
	Call getConnectedadm

	'sequence number = vc_22
	'legacy batch = vc_23
	'legacy project = vc_24
	'legacy salt code = vc_25
	'legact salt multiplicity = vc_26
	'legacy compound date = vc_27
	'legacy batch date = vc_28

	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM arx_reg_base_molecules_am ORDER BY cd_id ASC"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		If rec("just_batch") = "00" Then
			justReg = rec("vc_22")
			regId = "AT-"&rec("vc_22")&"-00"
			justBatch = "00"
			parentCdId = 0
		Else
			justReg = rec("vc_22")
			regId = "AT-"&rec("vc_22")&"-0"&rec("vc_23")
			justBatch = "0"&rec("vc_23")
			Set rec2 = server.CreateObject("ADODB.Recordset")
			strQuery = "SELECT * FROM arx_reg_base_molecules_am WHERE just_reg="&SQLClean(justReg,"T","S")&" and just_batch='00'"
			rec2.open strQuery,jchemRegConn,3,3
			If Not rec2.eof then
				parentCdId = rec2("cd_id")
			Else
				parentCdId = 999999
			End if
			rec2.close
			Set rec2 = nothing
		End If
		strQuery = "UPDATE arx_reg_base_molecules_am SET "&_
					"just_reg="&SQLClean(justReg,"T","S")&","&_
					"reg_id="&SQLClean(regId,"T","S")&","&_
					"just_batch="&SQLClean(justBatch,"T","S")&","&_
					"parent_cd_id="&SQLClean(parentCdId,"N","S")&" "&_
					"WHERE cd_id="&SQLClean(rec("cd_id"),"N","S")
		jchemRegConn.execute(strQuery)
		response.write(strQuery&"<br/>")
		rec.movenext
	loop
	rec.close
	Set rec = Nothing
	
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM arx_reg_base_molecules_am ORDER BY cd_id ASC"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		projectName = rec("vc_24")
		If projectName <> "" then
			Set rec2 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM projectsView WHERE name="&SQLClean(projectName,"T","S")&" AND companyId=47"
			response.write(strQuery)
			rec2.open strQuery,connAdm,3,3
			projectId = rec2("id")
			rec2.close
			Set rec2= Nothing
			
			strQuery = "INSERT into linksProjectReg(projectId,cd_id) values("&SQLClean(projectId,"N","S")&","&SQLClean(rec("cd_id"),"N","S")&")"
			connAdm.execute(strQuery)
			response.write(strQuery&"<br/>")
		End if
		rec.moveNext
	Loop
	rec.close
	Set rec = nothing

	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM arx_reg_base_molecules_am ORDER BY cd_id ASC"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		If Not IsNull(rec("vc_25")) Then
			If rec("vc_25") <> "" then
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT * FROM arx_reg_salts_am WHERE salt_code="&SQLClean(rec("vc_25"),"T","S")
				rec2.open strQuery,jchemRegConn,3,3
				strQuery = "INSERT into saltMappings(saltId,molId,multiplicity) values("&SQLClean(rec2("cd_id"),"N","S")&","&SQLClean(rec("cd_id"),"N","S")&","&SQLClean(rec("vc_26"),"N","S")&")"
				
				jchemRegConn.execute(strQuery)
				response.write(strQuery&"<br/>")
				rec2.close
			End if
		End if
		Set rec2 = nothing
		rec.moveNext
	Loop
	rec.close
	Set rec = Nothing
	
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM arx_reg_base_molecules_am ORDER BY cd_id ASC"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		If rec("just_batch") = "00" Then
			strQuery = "update arx_reg_base_molecules_am SET cd_timestamp=vc_27 WHERE cd_id="&SQLClean(rec("cd_id"),"N","S")
		else
			strQuery = "update arx_reg_base_molecules_am SET cd_timestamp=vc_28 WHERE cd_id="&SQLClean(rec("cd_id"),"N","S")
		End If
		jchemRegConn.execute(strQuery)
		response.write(strQuery&"<br/>")
		rec.moveNext
	Loop
	rec.close
	Set rec = nothing

	Call disconnectJchemReg
	Call disconnectadm
End if
%>