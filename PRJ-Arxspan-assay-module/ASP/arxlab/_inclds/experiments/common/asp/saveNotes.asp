<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
prefix = GetPrefix(experimentType)
notesTable = GetFullName(prefix, "notes", true)
notesHistoryTable = GetFullName(prefix, "notes_history", true)
notesPreSaveTable = GetFullName(prefix, "notes_preSave", true)

' Generate xml structure of notes that were updated during this editing session
updatedNoteXml = "<noteList>"
Set attachmentRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, name, note FROM "&notesTable&" WHERE readOnly = 0 AND experimentId="&SQLClean(experimentId,"N","S")
attachmentRec.open strQuery,connAdmTrans,3,3
Do While Not attachmentRec.eof
	' 9118: I could not reproduce this issue at all in Dev. This fix is a shoot in the dark but I think it may have a good chance of fixing it. If not, we can then spend more time to trace it.
	If experimentJSON.exists("note_"&attachmentRec("id")&"_description") Then
		noteDesc = experimentJSON.get("note_"&attachmentRec("id")&"_description")
	Else
		noteDesc = attachmentRec("note")
	End If
	If experimentJSON.exists("note_"&attachmentRec("id")&"_name") Then
		noteName = experimentJSON.get("note_"&attachmentRec("id")&"_name")
	Else
		noteName = attachmentRec("name")
	End If
	If attachmentRec("note") <> noteDesc or attachmentRec("name") <> noteName Then
		updatedNoteXml = updatedNoteXml & "<note>"
		updatedNoteXml = updatedNoteXml & "<id>" & attachmentRec("id") & "</id>"
		updatedNoteXml = updatedNoteXml & "<noteName>" & SQLClean(noteName,"T-PROC","XML") & "</noteName>"
		updatedNoteXml = updatedNoteXml & "<noteText>" & SQLClean(noteDesc,"T-PROC","XML") & "</noteText>"
		updatedNoteXml = updatedNoteXml & "</note>"
	End if
	attachmentRec.moveNext
Loop
attachmentRec.close
updatedNoteXml = updatedNoteXml & "</noteList>"

'Generate xml structure of new notes created during this editing session
newNoteXml = "<noteList>"
' Don't use the exeprimentType from the preSave table in the sub-query becuase it can be NULL.
strQuery = "SELECT id, readOnly FROM "&notesPreSaveTable&" a WHERE experimentId="&SQLClean(experimentId,"N","S") &_
		" AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='note' AND r.experimentId=a.experimentId AND r.experimentType=" & SQLClean(experimentType,"N","S") & " AND r.pre=1)"
attachmentRec.open strQuery,connAdmTrans,3,3
Do While Not attachmentRec.eof
	html = experimentJSON.get("note_p_"&attachmentRec("id")&"_description")
	If (TypeName(confirmExperimentIdAtt) <> "Long") Then
		rowCount = UBound(confirmExperimentIdAtt,2)
		For i=0 To rowCount
			html = Replace(html,"getImage.asp?id="&confirmExperimentIdAtt(1,i)&"&experimentType="&experimentType&"&pre=true","getImage.asp?id="&confirmExperimentIdAtt(0,i)&"&experimentType="&experimentType)
			html = Replace(html,"getImage.asp?id="&confirmExperimentIdAtt(1,i)&"&amp;experimentType="&experimentType&"&amp;pre=true","getImage.asp?id="&confirmExperimentIdAtt(0,i)&"&experimentType="&experimentType)
		next
	End if
	
	newNoteXml = newNoteXml & "<note>"
	newNoteXml = newNoteXml & "<readOnly>" & attachmentRec("readOnly") & "</readOnly>"
	newNoteXml = newNoteXml & "<noteName>" & SQLClean(experimentJSON.get("note_p_"&attachmentRec("id")&"_name"),"T-PROC","XML") & "</noteName>"
	newNoteXml = newNoteXml & "<noteText>" & SQLClean(html,"T-PROC","XML") & "</noteText>"
	newNoteXml = newNoteXml & "</note>"

	attachmentRec.movenext
Loop
attachmentRec.close
Set attachmentRec = nothing
newNoteXml = newNoteXml & "</noteList>"

'Call stored procedure to save notes
Set args = JSON.parse("{}")
Call addStoredProcedureArgument(args, "companyId", adBigInt, SQLClean(session("companyId"),"N","S"))
Call addStoredProcedureArgument(args, "userId", adBigInt, SQLClean(session("userId"),"N","S"))
Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
Call addStoredProcedureArgument(args, "updatedNotes", adLongVarChar, updatedNoteXml)
Call addStoredProcedureArgument(args, "newNotes", adLongVarChar, newNoteXml)
confirmExperimentId = callStoredProcedure("elnSaveExperimentNotes", args, True)
%>