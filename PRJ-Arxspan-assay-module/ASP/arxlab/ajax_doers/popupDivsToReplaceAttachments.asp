<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")
PID = "PID="&request.querystring("PID")

If experimentType <> "" Then
	prefix = GetPrefix(experimentType)
	attachmentsTable = GetFullName(prefix, "attachments", true)
	strQuery = "SELECT id, name, description, sortOrder, folderId FROM " & attachmentsTable & " WHERE experimentId="&SQLClean(experimentId,"N","S")
	Set attachmentRec = server.CreateObject("ADODB.RecordSet")
	attachmentRec.open strQuery,conn,0,-1
	Do While Not attachmentRec.eof
	%>
		<div id="addFileDiv_<%=attachmentRec("id")%>" class="popupDiv popupBox">
		<div class="popupFormHeader">Replace File</div>
		<form name="file_form_<%=attachmentRec("id")%>" method="post" action="<%=mainAppPath%>/experiments/upload-file.asp?<% = PID %>&experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&attachmentId=<%=attachmentRec("id")%>&random=<%=rnd%>" ENCTYPE="multipart/form-data" OnSubmit="unsavedChanges=true;sendAutoSave('experimentId',experimentJSON['experimentId']);return preUpload(<%=attachmentRec("id")%>);" class="popupForm" target="submitFrame2">
			<section class="popupFileUploadSection">
				<label for="file1">Replace Data For File: <%=Server.HTMLEncode(attachmentRec("name"))%></label>
				<div id="fileInputContainer" class="popupFileInputContainer"><input type="file" name="file1_<%=attachmentRec("id")%>" id="file1_<%=attachmentRec("id")%>"></div>
			</section>
			<input type="hidden" name="fileLabel" value="<%=Server.HTMLEncode(attachmentRec("name"))%>">
			<input type="hidden" name="description" value="<%=Server.HTMLEncode(attachmentRec("description"))%>">
			<input type="hidden" name="sortOrder" value="<%=attachmentRec("sortOrder")%>">
			<input type="hidden" name="folderId" value="<%=attachmentRec("folderId")%>">
			<section class="bottomButtons buttonAlignedRight">
				<button type="submit">Upload</button>
			</section>
		</form>
		</div>
	<%
		attachmentRec.movenext
	loop
End if

%>