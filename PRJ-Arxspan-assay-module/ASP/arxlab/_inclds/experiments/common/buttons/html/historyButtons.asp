<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%If canViewExperiment(experimentType,experimentId,session("userId")) then%>
	<%if checkedOutFiles <> "" then%>
		<a href="#" class="createLink" onclick="swal('Please Check-In or Discard Checked-Out Files', 'Currently Checked Out: <%=checkedOutFiles%>' , 'error');" id="copyExperimentButton"><%=copyExperimentButtonLabel%></a>	
	<%else%>
		<a href="javascript:void(0);" onclick="showPopup('copyDiv');return false;" class="createLink" id="copyExperimentButton"><%=copyExperimentButtonLabel%></a>
	<%end if%>
<%End if%>