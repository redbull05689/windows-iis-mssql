<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedadm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * from notebookInvites WHERE id=" & SQLClean(request.Form("inviteId"),"N","S") & ""
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	If (ownsNotebook(rec("notebookId")) Or rec("sharerId")=session("userId")) And hasShareNotebookPermission(false) Then
		If canShareShareNotebook(rec("notebookId")) then
			Select Case request.Form("newSharePermissions")
				Case "1"
					canShare = "0"
					canShareShare = "0"
					connAdm.execute("UPDATE notebookInvites SET canShare=0,canShareShare=0 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
					a = logAction(1,rec("notebookId"),"",12)
				Case "2"
					canShare = "1"
					canShareShare = "0"
					connAdm.execute("UPDATE notebookInvites SET canShare=1,canShareShare=0 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
					a = logAction(1,rec("notebookId"),"",12)
				Case "3"
					canShare = "1"
					canShareShare = "1"
					connAdm.execute("UPDATE notebookInvites SET canShare=1,canShareShare=1 WHERE id="&SQLClean(request.Form("inviteId"),"N","S"))
					a = logAction(1,rec("notebookId"),"",12)
			End Select
			children = getChildInvites(notebookId,shareeId)
			children = Split(children,",")
			For i = 0 To UBound(children)
				If canShare = "0" then	
					connAdm.execute("UPDATE notebookInvites SET canShare=0 WHERE id="&SQLClean(children(i),"N","S"))
				End if
				If canShareShare = "0" then	
					connAdm.execute("UPDATE notebookInvites SET canShareShare=0 WHERE id="&SQLClean(children(i),"N","S"))
				End if
			next
		End if
	End If
End If
%>
<div id="resultsDiv">success</div>