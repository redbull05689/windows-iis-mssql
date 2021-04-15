<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function preSaveItems(experimentType,experimentId)
	'return true if the specified experiment has preSave notes or attachments
	prefix = GetPrefix(CStr(experimentType))
	notesPreSave = GetFullName(prefix, "notes_preSave", true)
	attachmentsPreSave = GetFullName(prefix, "attachments_preSave", true)
	preSaveItems = false
	Set psiRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM " & notesPreSave & " WHERE experimentId="&SQLClean(experimentId,"N","S")
	psiRec.open strQuery,conn,3,3
	If Not psiRec.eof Then
		preSaveItems = true
	End If
	psiRec.close
	strQuery = "SELECT id FROM " & attachmentsPreSave & " WHERE experimentId="&SQLClean(experimentId,"N","S")
	psiRec.open strQuery,conn,3,3
	If Not psiRec.eof Then
		preSaveItems = true
	End If
	psiRec.close
	
	strQuery = "SELECT id FROM experimentLinks_preSave WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")
	psiRec.open strQuery,conn,3,3
	If Not psiRec.eof Then
		preSaveItems = true
	End If
	psiRec.close
	strQuery = "SELECT id FROM experimentRegLinks_preSave WHERE experimentType="&SQLClean(experimentType,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")
	psiRec.open strQuery,conn,3,3
	If Not psiRec.eof Then
		preSaveItems = true
	End If
	psiRec.close
end function
%>