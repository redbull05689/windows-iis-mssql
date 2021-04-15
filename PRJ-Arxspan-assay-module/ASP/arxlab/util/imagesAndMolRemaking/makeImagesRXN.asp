<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/globals.asp"-->
<%
server.scriptTimeout = 90000
%>
<%
If session("email") = "support@arxspan.com" And request.querystring("experimentId") <> "" And request.querystring("revisionNumber") <> 0 then
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM experiments_history where experimentId="&SQLClean(request.querystring("experimentId"),"N","S")&" AND revisionNumber="&SQLClean(request.querystring("revisionNumber"),"N","S")
	rec.open strQuery,conn,3,3
	Do While Not rec.eof
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		response.write("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(rec("userId"))&"_"&rec("userId")&"_"&rec("experimentId")&"_"&rec("revisionNumber")&"_"&Abs(session("hasCompoundTracking"))&"_notnew_rxn.rxn")
		set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(rec("userId"))&"_"&rec("userId")&"_"&rec("experimentId")&"_"&rec("revisionNumber")&"_"&Abs(session("hasCompoundTracking"))&"_notnew_rxn.rxn")
		tfile.WriteLine(Replace(rec("cdx"),"\""",""""))
		tfile.close
		set tfile=nothing
		set fs=nothing	
		rec.movenext
	loop
End if
%>
