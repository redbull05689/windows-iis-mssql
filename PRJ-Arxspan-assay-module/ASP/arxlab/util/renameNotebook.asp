<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%'not implemented here is the functionality to not have names changed where the name has more than one instance of oldName%>
<%if session("userId") = "2" then

notebookId = "592"
newName = "Evans-C-2012"
oldName = "Evans-I-2012"
test = True

response.write("<h1>NOTEBOOOK</h1>")

Call getconnectedadm
set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM notebooks WHERE id="&SQLClean(notebookId,"N","S")
rec.open strQuery,connAdm,3,3
	notebookName = rec("name")
	strQuery2 = "UPDATE notebooks SET name="&SQLClean(Replace(notebookName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(notebookId,"N","S")
	If Not test Then
		connAdm.execute(strQuery2)
	End if
rec.close
Set rec = nothing

response.write("<h1>CHEMISTRY EXPERIMENTS</h1>")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM experiments WHERE notebookId="&SQLClean(notebookId,"N","S")
rec.open strQuery,connAdm,3,3
Do While Not rec.eof
	If rec("statusId") <> "5" And rec("statusId") <> "6" then
		experimentName = rec("name")
		experimentId = rec("id")
		response.write("experiment name: "&experimentName&"<br/>")
		strQuery2 = "UPDATE experiments set name="&SQLClean(Replace(experimentName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(experimentId,"N","S")
		If Not test Then
			connAdm.execute(strQuery2)
		End if
		
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery5 = "SELECT * FROM experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S")&" ORDER BY revisionNumber DESC"
		rec2.open strQuery5,connAdm,3,3
		If Not rec2.eof Then
				revisionName = rec2("name")
				revisionId = rec2("id")
				response.write("experiment name: "&experimentName&" revision:"&rec2("revisionNumber")&"<br/>")
				strQuery2 = "UPDATE experiments_history set name="&SQLClean(Replace(revisionName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(revisionId,"N","S")
				If Not test Then
					connAdm.execute(strQuery2)
				End if
		End If
	End if
	rec.movenext
loop



response.write("<h1>BIOLOGY EXPERIMENTS</h1>")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM bioExperiments WHERE notebookId="&SQLClean(notebookId,"N","S")
rec.open strQuery,connAdm,3,3
Do While Not rec.eof
	If rec("statusId") <> "5" And rec("statusId") <> "6" then
		experimentName = rec("name")
		experimentId = rec("id")
		response.write("experiment name: "&experimentName&"<br/>")
		strQuery2 = "UPDATE bioExperiments set name="&SQLClean(Replace(experimentName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(experimentId,"N","S")
		If Not test Then
			connAdm.execute(strQuery2)
		End if
		
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery5 = "SELECT * FROM bioExperiments_history WHERE experimentId="&SQLClean(experimentId,"N","S")&" ORDER BY revisionNumber DESC"
		rec2.open strQuery5,connAdm,3,3
		If Not rec2.eof Then
				revisionName = rec2("name")
				revisionId = rec2("id")
				response.write("experiment name: "&experimentName&" revision:"&rec2("revisionNumber")&"<br/>")
				strQuery2 = "UPDATE bioExperiments_history set name="&SQLClean(Replace(revisionName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(revisionId,"N","S")
				If Not test Then
					connAdm.execute(strQuery2)
				End if
		End If
	End if
	rec.movenext
loop

response.write("<h1>FREE EXPERIMENTS</h1>")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM freeExperiments WHERE notebookId="&SQLClean(notebookId,"N","S")
rec.open strQuery,connAdm,3,3
Do While Not rec.eof
	If rec("statusId") <> "5" And rec("statusId") <> "6" then
		experimentName = rec("name")
		experimentId = rec("id")
		response.write("experiment name: "&experimentName&"<br/>")
		strQuery2 = "UPDATE freeExperiments set name="&SQLClean(Replace(experimentName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(experimentId,"N","S")
		If Not test Then
			connAdm.execute(strQuery2)
		End if
		
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery5 = "SELECT * FROM freeExperiments_history WHERE experimentId="&SQLClean(experimentId,"N","S")&" ORDER BY revisionNumber DESC"
		rec2.open strQuery5,connAdm,3,3
		If Not rec2.eof Then
				revisionName = rec2("name")
				revisionId = rec2("id")
				response.write("experiment name: "&experimentName&" revision:"&rec2("revisionNumber")&"<br/>")
				strQuery2 = "UPDATE freeExperiments_history set name="&SQLClean(Replace(revisionName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(revisionId,"N","S")
				If Not test Then
					connAdm.execute(strQuery2)
				End if
		End If
	End if
	rec.movenext
loop

response.write("<h1>ANAL EXPERIMENTS</h1>")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM analExperiments WHERE notebookId="&SQLClean(notebookId,"N","S")
rec.open strQuery,connAdm,3,3
Do While Not rec.eof
	If rec("statusId") <> "5" And rec("statusId") <> "6" then
		experimentName = rec("name")
		experimentId = rec("id")
		response.write("experiment name: "&experimentName&"<br/>")
		strQuery2 = "UPDATE analExperiments set name="&SQLClean(Replace(experimentName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(experimentId,"N","S")
		If Not test Then
			connAdm.execute(strQuery2)
		End if
		
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery5 = "SELECT * FROM analExperiments_history WHERE experimentId="&SQLClean(experimentId,"N","S")&" ORDER BY revisionNumber DESC"
		rec2.open strQuery5,connAdm,3,3
		If Not rec2.eof Then
				revisionName = rec2("name")
				revisionId = rec2("id")
				response.write("experiment name: "&experimentName&" revision:"&rec2("revisionNumber")&"<br/>")
				strQuery2 = "UPDATE analExperiments_history set name="&SQLClean(Replace(revisionName,oldName,newName,1,1,0),"T","S")& " WHERE id="&SQLClean(revisionId,"N","S")
				If Not test Then
					connAdm.execute(strQuery2)
				End if
		End If
	End if
	rec.movenext
loop

Call disconnectadm
end if%>