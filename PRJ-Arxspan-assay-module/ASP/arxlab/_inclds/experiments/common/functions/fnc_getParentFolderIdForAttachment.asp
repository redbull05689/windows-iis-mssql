<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'loop through the database until it reaches the parentfolderId is NULL - top parent and insert into the fancytree JSON object 
Function getParentFolderId(parentFolderId, experimentId, experimentType, retValue)
	Call getConnected
	If Not IsNull(parentFolderId) Then
		If CLng(parentFolderId) <> 0 Then
			Set pRec = server.CreateObject("ADODB.Recordset")
			pStrQuery = "SELECT folderName, parentFolderId FROM attachmentFolders WHERE id="&SQLClean(parentFolderId,"N","S")&" AND experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
			pRec.open pStrQuery,conn,3,3
			If Not pRec.eof Then
				If len(retValue) = 0 Then
					retValue = "{'folderId': '"&parentFolderId&"', 'folderName': '"&pRec("folderName")&"', 'parentFolderId': '"&pRec("parentFolderId")&"'}"
				Else
					retValue = retValue &","& "{'folderId': '"&parentFolderId&"', 'folderName': '"&pRec("folderName")&"', 'parentFolderId': '"&pRec("parentFolderId")&"'}"
				End If
				Call getParentFolderId(pRec("parentFolderId"), experimentId, experimentType, retValue)
			End If
		End If
	End If
	getParentFolderId = retValue
	Call disconnect
End Function
%>