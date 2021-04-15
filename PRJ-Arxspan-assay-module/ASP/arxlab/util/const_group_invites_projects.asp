<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<%
if session("userId") = "2" And 1=2 then

	call getconnectedAdm
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery  = "SELECT * FROM projects WHERE id in (449,455,456,451,452,453,454,457,390,450,391,400)"
	rec.open strQuery,connAdm,3,3
	Do While Not rec.eof
		strQuery2 = "INSERT INTO groupProjectInvites(projectId,sharerId,shareeId,accepted,denied,canRead,canWrite,readOnly) values(" &_
						SQLClean(rec("id"),"N","S") & "," &_
						SQLClean(rec("userId"),"N","S") & "," &_
						SQLClean("71","N","S") & ",1,0,1,1,1)"
		connAdm.execute(strQuery2)
		rec.movenext
	loop
	call disconnectadm
end If
%>