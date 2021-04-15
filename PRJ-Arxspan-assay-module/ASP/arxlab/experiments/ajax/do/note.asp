<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<!-- #include file="../../../_inclds/globals.asp"-->


<%
'add a note to an experiment with text and title
Call getconnectedadm
Call getconnected
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")

'only the owner of the experiment may add a note
If ownsExperiment(experimentType,experimentId,session("userId")) then
	'get the correct table names
	prefix = GetPrefix(experimentType)
	experimentHistoryTable = GetFullName(prefix, "experiments_history", true)
	notesPreSaveTable = GetFullName(prefix, "notes_preSave", true)

	'get experiment revision number
	Set rs = Server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM "&experimentHistoryTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")
	rs.open strQuery,conn,3,3
	revisionNumber = rs.recordCount + 1

	'add note to experiment and return new note id
	Call getconnectedadm
	strQuery = "INSERT into "&notesPreSaveTable&"(userId,experimentId,name,note,revisionNumber,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer) values(" &_
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean(request.Form("noteName"),"T","S") & "," &_
				SQLClean(request.Form("noteText"),"T","S") & "," &_
				SQLClean(revisionNumber,"N","S")&",GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE())"
	connAdm.execute(strQuery)

	response.write(request.Form("noteText"))
End if
%>
<!-- #include file="../../../_inclds/notes/asp/noteNotifications.asp"-->
<div id="resultsDiv">success</div>