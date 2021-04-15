<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scripttimeout=600%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
inboxPath = getCompanySpecificSingleAppConfigSetting("dispatchInboxDirectory", session("companyId"))
'list or re-send office attachments that do not have PDFs

if session("email") = "support@arxspan.com" then

	if request.form("listSubmit") <> "" Or request.Form("resendSubmit") <> "" Or request.Form("replaceBlankSubmit") <> "" Then
		Call getconnected
		types = Split("chem,bio,free,anal",",")

		count = 0
		For i = 0 To UBound(types)
			thisType = types(i)
			Select Case thisType
				case "chem"
					attachmentsTableName = "attachments"
					experimentType = 1
					experimentPage = session("expPage")
				case "bio"
					attachmentsTableName = "bioAttachments"
					experimentType = 2
					experimentPage = "bio-experiment.asp"
				case "free"
					attachmentsTableName = "freeAttachments"
					experimentType = 3
					experimentPage = "free-experiment.asp"
				case "anal"
					attachmentsTableName = "analAttachments"
					experimentType = 4
					experimentPage = "anal-experiment.asp"
			End Select
			Set rec = server.CreateObject("ADODB.RecordSet")
			'get attachments from the appropriate table for this company where the experiment has not been deleted.
			strQuery = "SELECT * FROM "&attachmentsTableName&" WHERE userId in (SELECT id FROM users WHERE companyId="&SQLClean(session("companyId"),"N","S")&") and experimentId in (SELECT experimentId FROM notebookIndex WHERE visible=1 and typeId="&SQLClean(experimentType,"N","S")&")"
			rec.open strQuery,conn,0,-1
			Do While Not rec.eof
				filePath = getAttachmentFilePath(experimentType,rec("id"),"","",false)
				If isOfficeDoc(rec("actualFileName")) Then
					dim fs
					set fs=Server.CreateObject("Scripting.FileSystemObject")
					If Not fs.fileExists(filepath&".pdf") Then
						count = count + 1
						%>
						<%=count%>. <%=rec("experimentId")%>&nbsp;<%=rec("filesize")%>b <a href="<%=mainAppPath%>/<%=experimentPage%>?id=<%=rec("experimentId")%>&expView=true&tab=attachmentTable&attachmentId=<%=rec("id")%>"> <%=rec("actualFileName")%></a> <%=rec("filename")%><br/>
						<%
						If request.Form("resendSubmit") <> "" then
							fs.CopyFile filepath,inboxPath&"\"&whichServer&"_"&getCompanyIdByUser(rec("userId"))&"_"&rec("userId")&"_"&rec("experimentId")&"_"&rec("revisionNumber")&"_"&thisType&"_"&rec("actualFileName")
						End If
						If request.Form("replaceBlankSubmit") <> "" Then
							fs.CopyFile Server.MapPath("/")&mainAppPath&"/static/blank.pdf",filepath&".pdf"
						End if
					End if
					set fs=nothing
				End If
				rec.movenext
			Loop
			rec.close
			Set rec = nothing
		next
		Call disconnect
	end if
%>
	<form action="resendAttachmentsToInbox.asp" method="POST" onsubmit="return confirm('Are you sure? If you are resending or replacing this could do some damage!')">
		<input type="submit" name="listSubmit" value="LIST">
		<input type="submit" name="resendSubmit" value="RESEND">
		<input type="submit" name="replaceBlankSubmit" value="REPLACE WITH BLANK PDF">
	</form>
<%
end if
%>