<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%
server.scriptTimeout = 90000
%>
<%
If session("userId") = "2" then
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM experiments"
rec.open strQuery,conn,3,3
Do While Not rec.eof
	set fs=Server.CreateObject("Scripting.FileSystemObject")
	response.write("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(rec("userId"))&"_"&rec("userId")&"_"&rec("id")&"_"&rec("revisionNumber")&"_prods.prods")
	set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(rec("userId"))&"_"&rec("userId")&"_"&rec("id")&"_"&rec("revisionNumber")&"_prods.prods")
	tfile.WriteLine(rec("molData"))
	tfile.close
	set tfile=nothing
	set fs=nothing	
	rec.movenext
loop
End if
%>