<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
currentFlag = false
If revisionId = "" Then
	pdfRevisionId = getExperimentRevisionNumber(experimentType,experimentId)
	currentFlag = True
Else
	pdfRevisionId = revisionId
End if
set fs=Server.CreateObject("Scripting.FileSystemObject")
experimentTypeName = GetAbbreviation(experimentType)
signFileName = uploadRoot & "\" & expUserId & "\" & experimentId & "\" & pdfRevisionId & "\" & experimentTypeName & "\sign.pdf"
shortSignFileName = uploadRoot & "\" & expUserId & "\" & experimentId & "\" & pdfRevisionId & "\" & experimentTypeName & "\sign-short.pdf"
%>
<a href="signed.asp?id=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>" class="createLink" id="showPDFLink"<%If currentFlag then%> onclick="if(unsavedChanges){unsavedChanges=false;return confirm('This experiment currently has unsaved changes.  Unsaved changes will not be shown in the PDF.')}" <%End if%> style="display:none;"><%=showPdfVersionButtonLabel%></a>
<%
If fs.fileExists(signFileName) Or statusId=5 Or statusId=6 Then
	%>
	<script type="text/javascript">document.getElementById("showPDFLink").style.display = 'block';</script>
	<%
Else
	if experimentType = 5 then
	%>
	<a id="makePDFLink" <%If currentFlag then%> onclick="custConfirmPdf('<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>', <%=experimentId%>, <%=experimentType%>);" <%End if%>class="createLink"><%=showPdfVersionButtonLabel%></a>
	<%
	else 
	%>
	<a href="<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>"  id="makePDFLink" <%If currentFlag then%> onclick="if(unsavedChanges){unsavedChanges=false;return confirm('This experiment currently has unsaved changes.  Unsaved changes will not be shown in the PDF.')}" <%End if%>class="createLink"><%=showPdfVersionButtonLabel%></a>
	<%
	End if
End If
%>

<a href="signed.asp?id=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>&short=1" class="createLink" id="showShortPDFLink"<%If currentFlag then%> onclick="if(unsavedChanges){unsavedChanges=false;return confirm('This experiment currently has unsaved changes.  Unsaved changes will not be shown in the PDF.')}" <%End if%> style="display:none;">Short PDF</a>

<%If session("hasShortPdf") then%>
<%
If fs.fileExists(shortSignFileName) Then
	%>
	<script type="text/javascript">document.getElementById("showShortPDFLink").style.display = 'block';</script>
	<%
Else
	%>
	<a href="<%=mainAppPath%>/experiments/makePDFVersion.asp?experimentId=<%=experimentId%>&experimentType=<%=experimentType%>&revisionNumber=<%=pdfRevisionId%>&short=1" id="makeShortPDFLink" <%If currentFlag then%> onclick="if(unsavedChanges){unsavedChanges=false;return confirm('This experiment currently has unsaved changes.  Unsaved changes will not be shown in the PDF.')}" <%End if%>class="createLink">Short PDF</a>
	<%
End If
%>
<%End if%>