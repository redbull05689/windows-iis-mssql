<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% Server.ScriptTimeout = 300000%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="aspZip.class.asp"-->
<%
call getConnectedAdm
dim zip
set rec = server.createobject("ADODb.RecordSet")
strQuery = "SELECT id, exportPath, endFile FROM exports WHERE status=0 AND userId={userIdStr} AND endFile LIKE '%bulkExportTemp\{companyId}\%'"
strQuery = Replace(strQuery, "{userIdStr}", SQLClean(session("userId"),"N","S")) 
strQuery = Replace(strQuery, "{companyId}", SQLClean(session("companyId"),"N","S"))
rec.open strQuery,connAdm,3,3
if not rec.eof then	
    connAdm.execute("UPDATE exports SET status=1 WHERE id="&SQLClean(rec("id"),"N","S"))
	set zip = new aspZip
	zip.OpenArquieve(rec("endFile"))
	zip.Add(rec("exportPath"))
	zip.CloseArquieve()
	Set zip = nothing
	connAdm.execute("WAITFOR DELAY '00:00:03'")
	connAdm.execute("UPDATE exports SET status=2 WHERE id="&SQLClean(rec("id"),"N","S"))
Else
	response.write("Nothing to process")
end if
response.write("DONE")

call disconnectAdm
%>
