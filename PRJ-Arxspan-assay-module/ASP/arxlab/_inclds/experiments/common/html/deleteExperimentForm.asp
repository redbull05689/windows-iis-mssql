<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<form method="post" action="<%=mainAppPath%>/experiments/ajax/do/delete-experiment.asp" id="deleteForm" target="submitFrame">
<input type="hidden" name="experimentId" id="experimentId" value="<%=experimentId%>">
<input type="hidden" name="experimentType" id="experimentType" value="<%=experimentType%>">
</form>