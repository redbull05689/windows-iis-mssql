<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
dim efields
Sub ErrorChkText (strtext,formname)
	If instr(efields,formname&",") Then %><font color="red"><%= strtext %></font><%ELSE%><%= strtext %><%END IF	
End Sub
%>
