<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
tabId = request.querystring("tabId")
name = request.querystring("name")

Call getconnectedadm

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM projects WHERE parentProjectId is not null and id="&SQLClean(tabId,"N","S")
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	If ownsProject(rec("parentProjectId")) or (session("canDelete") and session("role")="Admin") Then
		strQuery = "UPDATE projects set name="&SQLClean(name,"T","S")&" WHERE id="&SQLClean(tabId,"N","S")
		connAdm.execute(strQuery)
	End if
End if

Call disconnectadm()
%>