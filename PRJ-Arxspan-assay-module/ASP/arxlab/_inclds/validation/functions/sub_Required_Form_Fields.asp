<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Sub Required_Form_Fields (Req_frm_Fields)
	'UDSAGE 
	'call Required_Form_Fields("first_name,last_name,email")
	'NOTE efields var MUST be Dimmed OUTSIDE Subs
	Dim FormfieldsChk,frmnum
	'Req_frm_Fields must be in this format "formfield1,formfield2, etc"
	If Req_frm_Fields<>"" then
		
		'Check that the required field is not empty
		FormfieldsChk = split(Req_frm_Fields,",")
		'Lets loop thru the fields and check them.
		For frmnum = 0 to Ubound(FormfieldsChk)
			
		if trim(request.form(FormfieldsChk(frmnum))) = "" then
			efields = efields & FormfieldsChk(frmnum)&","
		end if
		Next
		
	End if
End Sub
%>