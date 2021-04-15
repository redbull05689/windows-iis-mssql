<%
dim efields
Sub ErrorChkText (strtext,formname)
	If instr(efields,formname&",") Then %><font color="red"><%= strtext %></font><%ELSE%><%= strtext %><%END IF	
End Sub
%>
