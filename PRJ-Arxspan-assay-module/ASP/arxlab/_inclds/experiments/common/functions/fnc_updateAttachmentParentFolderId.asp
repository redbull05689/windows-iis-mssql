<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../chem/functions/fnc_copyChemistryData.asp"-->
<%
function updateAttachmentParentFolderId(experimentType,experimentId)
	'Update parentfolderId column after the upload
		Call getconnectedAdm
		Set rRec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id, fullPath FROM attachmentFolders WHERE experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S")
		rRec.open strQuery,connAdm,adOpenForwardOnly,adLockReadOnly
			
		Do While Not rRec.eof
			parentPath = ""
			s = Split(rRec("fullPath"), "/")
			For i=0 to ubound(s)-2
				parentPath = parentPath & s(i) &"/"
			Next
			If uBound(s) > 1 Then
				strUpdate = "DECLARE @parentId BIGINT; SELECT TOP 1 @parentId = id FROM attachmentFolders WHERE folderName="&SQLClean(s(uBound(s)-2),"T","S") & " AND experimentType="& SQLClean(experimentType,"N","S") & " AND experimentId="& SQLClean(experimentId,"N","S") & " AND fullPath=" & SQLClean(parentPath,"T", "S") &_
						" IF (@parentId > 0) UPDATE attachmentFolders SET parentFolderId=@parentId WHERE Id=" & SQLClean(rRec("Id"),"N","S")
				connAdm.execute(strUpdate)					
			End If
			rRec.movenext
		Loop
		Call disconnectAdm
end function
%>