<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<option value="-1">---SELECT---</option>
<%
Set notebookRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT notebookId,userId,name,visible,lastViewed,description,fullName FROM allNotebookPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and ((ISNULL(accepted, 1)=1 and canWrite=1) or canWrite is null) order by lastViewed DESC"
notebookRec.open strQuery,conn,0,-1
Do While Not notebookRec.eof
	%>
		<option value="<%=notebookRec("NotebookId")%>"<%If CStr(notebookRec("notebookId"))=CStr(session("defaultNotebookId")) then%> selected<%End if%> title="<%=notebookRec("description")%>"><%=notebookRec("name")%></option>
	<%
	notebookRec.movenext
Loop
notebookRec.Close
Set notebookRec = Nothing
%>
