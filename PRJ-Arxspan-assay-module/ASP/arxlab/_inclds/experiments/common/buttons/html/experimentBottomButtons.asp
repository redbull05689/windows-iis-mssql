<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../js/signedJS.asp"-->


<div class="expButtons" style="display:none;" id="submitRow">
<%If revisionId = "" and (ownsExp or canWrite) Or session("role") = "Admin" then%>
	<!-- #include file="experimentSaveButtons.asp"-->
<%End if%>

<%If Not(session("useSAFE") And session("softToken")) And Not(companyUsesSso() And session("isSsoUser")) And Not session("useGoogleSign") Then%>
	<%''To show witness buttons in experiment view page ELN 388
	Call getconnected
	Set witnessRec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT id FROM witnessRequests WHERE accepted=0 and denied=0 and requesteeId="&SQLClean(session("userId"),"N","S") & " AND experimentId="&SQLClean(experimentId,"N","S")
	witnessRec.open strQuery,conn,3,3
	%>
	<%If statusId = 5 And Not witnessRec.eof then%>
		<div class="buttonHolder" style="position:absolute;" id="witnessButtons">
			<%'5/25/2017 ELN-1003%>
			<div style="display:none;">
				<form method="post" id="denyForm" name="denyForm" action="<%=mainAppPath%>/experiments/denyWitness.asp" target="submitFrame">
					<input type="hidden" name="experimentId" value="<%=experimentId%>">
					<input type="hidden" name="experimentType" value="<%=experimentType%>">
					<input type="hidden" name="requestId" value="<%=witnessRec("id")%>">
					<input type="hidden" name="reason" id="reason" value="">
				</form>
			</div>
			<%'5/25/2017 %>
			<a href="javascript:void(0);" onclick="showPopup('reasonDiv')" class="createLink"><%=rejectButtonLabel%></a>
			<%If companyUsesSso() And session("isSsoUser") then%>
			<a href="javascript:void(0);" onclick="showPopup('ssoWitnessSignDiv')" class="createLink"><%=witnessButtonLabel%></a>
			<%ElseIf softSigned Or session("useGoogleSign") then%>
			<a href="javascript:void(0);" onclick="softWitness()" class="createLink"><%=witnessButtonLabel%></a>
			<%else%>
			<a href="javascript:void(0);" onclick="showPopup('witnessSignDiv')" class="createLink"><%=witnessButtonLabel%></a>
			<%End if%>
		</div>
	<%End if%>
<%End If%>
	
<!-- #include file="historyButtons.asp"-->
<!-- #include file="pdfButton.asp"-->
<%
'5 signed, 6 signed and witnessed, 10 pending not Pursued , 11 not Pursued
'I am checking the status like this because arrays in asp suck and take more space and memory to do then just this.
If (currentRevisionNumber = maxRevisionNumber) and (ownsExp or isCoAuthor or session("roleNumber") = 1) and (statusId <> 5 or statusId <> 6 or statusId <> 10 or statusId <> 11) then%>
	<a href="javascript:void(0);" onclick="abandonExperiment();" class="createLink"><%=notPursuedButtonLabel%></a>
<%End If%>
</div>

