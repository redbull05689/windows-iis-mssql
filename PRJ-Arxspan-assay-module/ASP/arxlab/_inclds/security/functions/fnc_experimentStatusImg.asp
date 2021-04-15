<%
function experimentStatusImg(status)
	Select Case status
		Case "regulatory check"
			statusImg = "style=""background-image:url(/arxlab/images/goldstar.png);"""
		Case "created"
			statusImg = "style=""background-image:url(/arxlab/images/newCreateIcon.gif);"""
		Case "saved"
			statusImg = "style=""background-image:url(/arxlab/images/newSavedIcon.gif);"""
		Case "reopened"
			statusImg = "style=""background-image:url(/arxlab/images/newReopenedIcon.gif);""" 
		Case "signed - open"
			statusImg = "style=""background-image:url(/arxlab/images/newSignedIcon.gif);"""
		Case "signed - closed"
			statusImg = "style=""background-image:url(/arxlab/images/newSignedIcon.gif);""" 
		Case "witnessed"
			statusImg = "style=""background-image:url(/arxlab/images/newWitnessedIcon.gif);"""
		Case "rejected"
			statusImg = "style=""background-image:url(/arxlab/images/newRejectedIcon.gif);"""
		Case "Pending Not Pursued"
			statusImg = "style=""background-image:url(/arxlab/images/newPendingAbandonmentIcon.gif);"""
		Case "Not Pursued"
			statusImg = "style=""background-image:url(/arxlab/images/newAbandonedIcon.gif);"""
	End select
	experimentStatusImg = statusImg
end function
%>