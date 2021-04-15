<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%
attachmentId = request.querystring("attachmentId")
parentFolderId = request.querystring("parentFolderId")
folderId = request.querystring("folderId")
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")

If IsNull(folderId) or IsEmpty(folderId) or folderId = "undefined" Then
	folderId = 0
End If

If ownsExperiment(experimentType,experimentId,session("userId")) Then
	If (SQLClean(attachmentId,"N","S") > 0) Then
		'dragged item is a file
		'Update folderId after moving the files
		'get path names and database tables
		prefix = GetPrefix(experimentType)
		attachmentsTable = GetFullName(prefix, "attachments", true)

		Call getconnectedAdm
			strUpdate = "UPDATE "&attachmentsTable&" SET folderId="&SQLClean(parentFolderId,"N","S")&" WHERE Id=" & SQLClean(attachmentId,"N","S") &" AND experimentId=" & SQLClean(experimentId,"N","S") &" AND experimentType="&SQLClean(experimentType,"N","S")
			connAdm.execute(strUpdate)
		Call disconnectAdm
	ElseIf (SQLClean(folderId,"N","S") > 0) Then
		'Dragged item is a folder
		'update the parent folderId for the folder
		Call getconnectedAdm
			strUpdate = "UPDATE attachmentFolders SET parentFolderId="&SQLClean(parentFolderId,"N","S")&" WHERE Id=" & SQLClean(folderId,"N","S") &" AND experimentId=" & SQLClean(experimentId,"N","S") &" AND experimentType="&SQLClean(experimentType,"N","S")
			connAdm.execute(strUpdate)
		Call disconnectAdm
	Else
	'Update parentfolderId column after the upload
		Call getconnectedAdm
			Set rRec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM attachmentFolders WHERE experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S")
			rRec.open strQuery,connAdm,3,3
			
			Do While Not rRec.eof
				parentPath = ""
				s = Split(rRec("fullPath"), "/")
				For i=0 to ubound(s)-2
					parentPath = parentPath & s(i) &"/"
				Next
				If uBound(s) > 1 Then
					Set rec = server.CreateObject("ADODB.RecordSet")
					strQuery = "SELECT * FROM attachmentFolders WHERE experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S") & " AND folderName="&SQLClean(s(uBound(s)-2),"T","S") &" AND fullPath=" & SQLClean(parentPath,"T", "S")
					rec.open strQuery,connAdm,3,3
					
					If not rec.eof Then
						strUpdate = "UPDATE attachmentFolders SET parentFolderId="&SQLClean(rec("Id"),"N","S")&" WHERE Id=" & SQLClean(rRec("Id"),"N","S") &" AND experimentId=" & SQLClean(experimentId,"N","S") &" AND experimentType="&SQLClean(experimentType,"N","S")
						connAdm.execute(strUpdate)
					End If
					
				End If
				rRec.movenext
			Loop
		Call disconnectAdm
	End If
	response.end
End If
%>