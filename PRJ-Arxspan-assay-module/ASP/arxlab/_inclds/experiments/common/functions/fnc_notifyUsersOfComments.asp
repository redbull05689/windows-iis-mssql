
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function generateExperimentCommentEmailBody(commenterFullName,experimentLink,experimentName,experimentOwnerName,projectLink,projectName,comment,recipientIsMentioned)
	if recipientIsMentioned then
		textFragment = "mentioned you in a comment added to"
	else
		textFragment = "has added a comment to"
	end if
	emailBody = "User <b>" & commenterFullName & "</b> "&textFragment&" <a href="""&experimentLink&""">"&experimentName&"</a> (owner: "&experimentOwnerName&").<br/><br/>"&_
		"<b>Experiment Description:</b><br/>"&experimentDescription&"<br/><br/>"
	if projectName <> "" then
		emailBody = emailBody & "<b>Project:</b> "&"<a href="""&projectLink&""">"&projectName&"</a>"&"<br/><br/>"
	end if
	emailBody = emailBody & "<b>Comment:</b><br/>"&comment
	generateExperimentCommentEmailBody = emailBody
end function

function userHasCommentEmailsEnabled(userId)
	Set nRec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM userNotificationOptions WHERE userId=" & SQLClean(userId,"N","S") & " AND notificationTypeId=1 AND email=1"
	nRec2.open strQuery,connAdm,3,3
	userHasCommentEmailsEnabled = Not nRec2.eof
end function
%>