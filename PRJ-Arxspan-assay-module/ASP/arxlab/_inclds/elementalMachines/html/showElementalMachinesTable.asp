<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT userId, notebookId FROM notebookIndex WHERE experimentId=" & SQLClean(experimentId,"N","S") & " AND typeId=" & SQLClean(experimentType,"N","S")
rec.open strQuery,conn,3,3
If Not rec.eof then
	canWrite = canWriteNotebook(CStr(rec("notebookId")))
	If session("userId") = rec("userId") Then
		ownsExp = True
	Else
		ownsExp = false
	End if
Else
	canWrite = False
	ownsExp = false
End If
canView = canViewExperiment(experimentType,experimentId,session("userId"))
%>
<script>
    var ie8 = false;
</script>

<!--[if IE 8]>
    <script>
        ie8 = true;
    </script>
<![endif]-->
<table cellpadding="0" cellspacing="0" class="attachmentsIndexTable">
<col width="250px">
<col width="200px">
<col width="500px">
<%If revisionId = "" And ownsExp then%>
<col width="50px">
<%End If%>
<tr>
<th>Machine Name</th>
<th>Date Added(<span id="tz1"><%If session("useGMT") then%><%="GMT"%><%End if%></span><%If Not session("useGMT") then%><script type="text/javascript">document.getElementById("tz1").innerHTML = (new Date()).format("Z");</script><%End if%>)</th>
<th>Data</th>
<%If revisionId = "" And ownsExp then%>
<th>Annotations*</th>
<th>Actions</th>
<%End If%>
</tr>
<%
If canView then
	Set attachmentRec = server.CreateObject("ADODB.Recordset")
	strQuery = "SELECT id, machineName, machineGuid, startTime, endTime, dateAdded, dateAddedServer, annotation from elementalMachinesData WHERE visible=1 and experimentType="&SQLClean(experimentType,"N","S")&" and experimentId="&SQLClean(experimentId,"N","S")
	If revisionId <> "" Then
		strQuery = strQuery & " and revisionNumber<="&SQLClean(revisionId,"N","S")
	End If
	strQuery = strQuery & " ORDER BY dateAddedServer DESC"
	attachmentRec.open strQuery,conn,3,3
	counter = 0
	Do While Not attachmentRec.eof
		counter = counter + 1
		%>
			<tr id="emData_p_<%=attachmentRec("id")%>_tr">
			<%
			If Trim(attachmentRec("machineName")) = "" Then
				noteName = "Untitled"
			Else
				noteName = attachmentRec("machineName")
			End if
			%>
			<td><a href="https://dashboard.elementalmachines.io/managed_machines/<%=attachmentRec("machineGuid")%>/" target="_blank" id="emData_p_<%=attachmentRec("id")%>_a"><%=maxChars(noteName,40)%></a><%If Len(note) >40 then%>...<%End if%></td>
			<td align="center" id="emData_p_<%=attachmentRec("id")%>_date_added">
				<script>setElementContentToDateString("<%="emData_p_"&attachmentRec("id")&"_date_added"%>", "<%=attachmentRec("dateAdded")%>",<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script>
			</td>			
			<td align="center" id="emData_p_<%=attachmentRec("id")%>_time_range"><script>getEMDataForRange("<%=attachmentRec("machineGuid")%>", "<%=attachmentRec("startTime")%>", "<%=attachmentRec("endTime")%>", "emData_p_<%=attachmentRec("id")%>_time_range")</script></td>
			<%
				If revisionId = "" And ownsExp then
					em_id = "emData_p_" & attachmentRec("id") & "_annotation"
			%>
			<td>
				<textarea id="<%=em_id%>" name="<%=em_id%>" class="em_annotation" rownum="<%=attachmentRec("id")%>" ><%=draftSet(em_id, attachmentRec("annotation"))%></textarea>
			</td>
			<td class="uploadButtons">
					<a href="javascript:void(0);" onclick="return removeTableItem('<%=mainAppPath%>/experiments/ajax/do/removeElementalMachinesData.asp?experimentType=<%=experimentType%>&experimentId=<%=experimentId%>&rowId=<%=attachmentRec("id")%>','emData_p_<%=attachmentRec("id")%>_tr');" class="littleButton">Remove</a>
			</td>
			<%End if%>
			</tr>
		<%
		attachmentRec.movenext
	Loop
	attachmentRec.close
End if
%>
</table>