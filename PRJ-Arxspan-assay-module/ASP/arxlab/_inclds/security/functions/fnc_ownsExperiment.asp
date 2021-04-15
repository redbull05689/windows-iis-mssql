<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function ownsExperiment(experimentType,experimentId,userId)
	'returns true if the user is the owner of the specified experiment
	' assume false
	ownsExperiment = False
	
	'get the right table by experiment type
	tableName = ""
	prefix = GetPrefix(experimentType)
	tableName = GetFullName(prefix, "experiments", true)

	If tableName <> "" Then
		'get the row of the experiment where the user is the owner
		oeRec = server.createobject("ADODB.RecordSet")
		Set oeRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id FROM "&tableName&" WHERE userId="&SQLClean(userId,"N","S") & " AND id="&SQLClean(experimentId,"N","S")
		oeRec.open strQuery,conn,3,3
		if not oeRec.eof then
			ownsExperiment = True
		end If
		oeRec.close
	
		'muf
		If ownsExperiment = False And session("hasMUFExperiment") And experimentType="3" Then
			strQuery = "SELECT notebookId from "&tableName&" WHERE id="&SQLClean(experimentId,"N","S")
			oeRec.open strQuery,conn,0,-1
			If Not oeRec.eof Then
				ownsExperiment = canWriteNotebook(oeRec("notebookId"))
			End If
			oeRec.close
		End if
		Set oeRec = Nothing
	End If
End Function
%>