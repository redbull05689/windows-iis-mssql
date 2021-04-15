<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
If preSaveItems(experimentType,experimentId) Then
		%>
		<script type="text/javascript">
			unsavedChanges = true;
		</script>
		<%
End if
%>