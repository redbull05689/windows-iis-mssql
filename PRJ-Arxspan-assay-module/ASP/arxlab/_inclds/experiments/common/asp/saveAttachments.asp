<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
expPrefix = getPrefix(experimentType)
attachmentsTable = getFullName(expPrefix, "attachments", true)
attachmentsHistoryTable = getFullName(expPrefix, "attachments_history", true)
attachmentsPreSaveTable = getFullName(expPrefix, "attachments_preSave", true)
folderPath = getAbbreviation(experimentType)

' Assemble data structure for existing attachments being updated
updatedAttachmentXml = "<attachmentList>"
Set attachmentRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, name, description, sortOrder, folderId FROM "&attachmentsTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
attachmentRec.open strQuery,connAdmTrans,3,3
Do While Not attachmentRec.eof
	If experimentJSON.exists("file_"&attachmentRec("id")&"_description") _
	   And experimentJSON.exists("file_"&attachmentRec("id")&"_name") _
	   Then
	    ' for backward compatibility, old records may not have sortOrder so we need to make a null one if it's not already there
	    If Not experimentJSON.exists("file_"&attachmentRec("id")&"_sortOrder") Or IsNull(experimentJSON.get("file_"&attachmentRec("id")&"_sortOrder")) Then
			experimentJSON.set "file_"&attachmentRec("id")&"_sortOrder", 0
	    End If
		If attachmentRec("description") <> experimentJSON.get("file_"&attachmentRec("id")&"_description") _
		   Or attachmentRec("name") <> experimentJSON.get("file_"&attachmentRec("id")&"_name") _
		   Or attachmentRec("sortOrder") <> experimentJSON.get("file_"&attachmentRec("id")&"_sortOrder") _
		   Then
			updatedAttachmentXml = updatedAttachmentXml & "<attachment>"
			updatedAttachmentXml = updatedAttachmentXml & "<id>" & attachmentRec("id") & "</id>"
			updatedAttachmentXml = updatedAttachmentXml & "<sortOrder>" & SQLClean(experimentJSON.get("file_"&attachmentRec("id")&"_sortOrder"),"N","S") & "</sortOrder>"
			updatedAttachmentXml = updatedAttachmentXml & "<folderId>" & SQLClean(experimentJSON.get("file_"&attachmentRec("id")&"_folderId"),"N","S") & "</folderId>"
			updatedAttachmentXml = updatedAttachmentXml & "<attachmentName>" & SQLClean(experimentJSON.get("file_"&attachmentRec("id")&"_name"),"T-PROC","XML") & "</attachmentName>"
			updatedAttachmentXml = updatedAttachmentXml & "<attachmentDesc>" & SQLClean(experimentJSON.get("file_"&attachmentRec("id")&"_description"),"T-PROC","XML") & "</attachmentDesc>"
			
			if experimentJSON.get("file_" & attachmentRec("id") & "_hideInPdf") <> "" then
				if experimentJSON.get("file_" & attachmentRec("id") & "_hideInPdf") = "true" or experimentJSON.get("file_" & attachmentRec("id") & "_hideInPdf") = true then
					updatedAttachmentXml = updatedAttachmentXml & "<hideInPdf>" & SQLCLean(1, "N", "S") & "</hideInPdf>"
				else
					updatedAttachmentXml = updatedAttachmentXml & "<hideInPdf>" & SQLCLean(0, "N", "S") & "</hideInPdf>"
				end if
			else
				updatedAttachmentXml = updatedAttachmentXml & "<hideInPdf>" & SQLCLean(0, "N", "S") & "</hideInPdf>"
			end if

			updatedAttachmentXml = updatedAttachmentXml & "</attachment>"
		End If
	End If
	attachmentRec.moveNext
Loop
attachmentRec.close
updatedAttachmentXml = updatedAttachmentXml & "</attachmentList>"

' Assemble data structure for new attachments
newAttachmentXml = "<attachmentList>"
' Don't use the exeprimentType from the preSave table in the sub-query becuase it can be NULL.
strQuery = "SELECT id FROM "&attachmentsPreSaveTable&" a WHERE experimentId="&SQLClean(experimentId,"N","S") &_
		" AND NOT EXISTS (SELECT 1 FROM itemsToRemove r WHERE r.itemId = a.id AND r.itemType='attachment' AND r.experimentId=a.experimentId AND r.experimentType=" & SQLClean(experimentType,"N","S") & " AND r.pre=1)"
attachmentRec.open strQuery,connAdmTrans,3,3
Do While Not attachmentRec.eof
	' for backward compatibility, old records may not have sortOrder so we need to make a null one if it's not already there
	If Not experimentJSON.exists("file_p_"&attachmentRec("id")&"_sortOrder") Or IsNull(experimentJSON.get("file_p_"&attachmentRec("id")&"_sortOrder")) Then
		experimentJSON.set "file_p_"&attachmentRec("id")&"_sortOrder", 0
	End If

	newAttachmentXml = newAttachmentXml & "<attachment>"
	newAttachmentXml = newAttachmentXml & "<id>" & attachmentRec("id") & "</id>"
	newAttachmentXml = newAttachmentXml & "<sortOrder>" & SQLClean(experimentJSON.get("file_p_"&attachmentRec("id")&"_sortOrder"),"N","S") & "</sortOrder>"
	newAttachmentXml = newAttachmentXml & "<folderId>" & SQLClean(experimentJSON.get("file_p_"&attachmentRec("id")&"_folderId"),"N","S") & "</folderId>"
	newAttachmentXml = newAttachmentXml & "<attachmentName>" & SQLClean(experimentJSON.get("file_p_"&attachmentRec("id")&"_name"),"T-PROC","XML") & "</attachmentName>"
	newAttachmentXml = newAttachmentXml & "<attachmentDesc>" & SQLClean(experimentJSON.get("file_p_"&attachmentRec("id")&"_description"),"T-PROC","XML") & "</attachmentDesc>"
	newAttachmentXml = newAttachmentXml & "</attachment>"

	attachmentRec.movenext
Loop
attachmentRec.close
Set attachmentRec = nothing
newAttachmentXml = newAttachmentXml & "</attachmentList>"

' Assemble data structure for section ordering in PDF
sectionOrderXml = "<sectionList>"
For Each fieldNameFromJSON In experimentJSON.keys()
	If InStr(1, fieldNameFromJSON, "section_") = 1 Then
		' Now handle the Content Sequence stuff for Experiment sections/fields
		experimentFieldName = Replace(fieldNameFromJSON,"section_","")
		experimentFieldName = Replace(experimentFieldName,"_sortOrder","")
		sectionSortOrderVal = experimentJSON.get(fieldNameFromJSON)
		
		If IsNull(sectionSortOrderVal) Then
			sectionSortOrderVal = 0
		End If

		sectionOrderXml = sectionOrderXml & "<section>"
		sectionOrderXml = sectionOrderXml & "<name>" & SQLClean(experimentFieldName,"T-PROC","S") & "</name>"
		sectionOrderXml = sectionOrderXml & "<sortOrder>" & SQLClean(sectionSortOrderVal,"N","S") & "</sortOrder>"
		sectionOrderXml = sectionOrderXml & "</section>"
	End If
Next
sectionOrderXml = sectionOrderXml & "</sectionList>"

'Call stored procedure to save attachments
Set args = JSON.parse("{}")
Call addStoredProcedureArgument(args, "companyId", adBigInt, SQLClean(session("companyId"),"N","S"))
Call addStoredProcedureArgument(args, "userId", adBigInt, SQLClean(session("userId"),"N","S"))
Call addStoredProcedureArgument(args, "experimentId", adBigInt, SQLClean(experimentId,"N","S"))
Call addStoredProcedureArgument(args, "experimentType", adInteger, SQLClean(experimentType,"N","S"))
Call addStoredProcedureArgument(args, "updatedAttachments", adLongVarChar, updatedAttachmentXml)
Call addStoredProcedureArgument(args, "newAttachments", adLongVarChar, newAttachmentXml)
Call addStoredProcedureArgument(args, "sectionOrder", adLongVarChar, sectionOrderXml)
confirmExperimentIdAtt = callStoredProcedure("elnSaveExperimentFiles", args, True)
%>