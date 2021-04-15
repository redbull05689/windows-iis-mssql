<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scripttimeout=600%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/fnc_sendProteinToSeurat.asp" -->
<%
if session("userId") = "2" Or session("email")="support@arxspan.com" And 1=1 then

	call getconnectedAdm
	call getconnectedAdm
	companyId=76
	tables = Split("attachments,bioAttachments,freeAttachments,analAttachments",",")
	For i = 0 To UBound(tables)
		tableName = tables(i)
		Select Case tableName
			Case "attachments"
				experimentType = 1
				typeFolder = "chem"
			Case "bioAttachments"
				experimentType = 2
				typeFolder = "bio"
			Case "freeAttachments"
				experimentType = 3
				typeFolder = "free"
			Case "analAttachments"
				experimentType = 4
				typeFolder = "anal"
		End select
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM "&tableName&" WHERE userId in (select id from users WHERE companyId="&SQLClean(companyId,"N","S")&")"
		rec.open strQuery,conn,0,-1
		Do While Not rec.eof
			actualFilename = rec("actualFilename")
			If isD2SDoc(actualFileName) Then
				response.write(getAttachmentFilePath(experimentType,rec("id"),"","",false)&"<br/>")
				response.write(inboxPathD2S&"\"&whichServer&"_"&getCompanyIdByUser(rec("userId"))&"_"&rec("userId")&"_"&rec("experimentId")&"_"&rec("revisionNumber")&"_"&typeFolder&"_"&actualFileName&"<br/><br/>")
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				fs.CopyFile getAttachmentFilePath(experimentType,rec("id"),"","",false) ,inboxPathD2S&"\"&whichServer&"_"&getCompanyIdByUser(rec("userId"))&"_"&rec("userId")&"_"&rec("experimentId")&"_"&rec("revisionNumber")&"_"&typeFolder&"_"&actualFileName
				set fs=nothing	
			End if
			rec.movenext
		loop
		rec.close
		Set rec = nothing
	next
	call disconnect	
	call disconnectadm
end If
%>