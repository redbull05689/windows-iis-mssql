<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="../../../_inclds/security/functions/fnc_checkCoAuthors.asp"-->
<%
'add a new empty note to the experiment
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")

isCollaborator = False
If experimentType = 5 Then
	isCollaborator = checkCoAuthors(experimentId, experimentType,"new-note")
End If

Call getconnected
Call getconnectedadm

'can only add note if the user is the experiment owner
If ownsExperiment(experimentType,experimentId,session("userId")) or isCollaborator Then
	'get the right table names
	prefix = GetPrefix(experimentType)
	historyTableName = GetFullName(prefix, "experiments_history", true)
	notesTableName = GetFullName(prefix, "notes_preSave", true)
	
	'get experiment revision number
	Set rs = Server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id FROM "&historyTableName&" WHERE experimentId="&SQLClean(experimentId,"N","S")
	rs.open strQuery,conn,3,3
	revisionNumber = rs.recordCount + 1

	'inser new note; return id of new note
	strQuery = "INSERT into "&notesTableName&"(userId,experimentId,name,note,revisionNumber,dateAdded,dateUpdated,dateAddedServer,dateUpdatedServer) output inserted.id as newId values(" &_
				SQLClean(session("userId"),"N","S") & "," &_
				SQLClean(experimentId,"N","S") & "," &_
				SQLClean("","T","S") & "," &_
				SQLClean("","T","S") & "," &_
				SQLClean(revisionNumber,"N","S")&",GETUTCDATE(),GETUTCDATE(),GETDATE(),GETDATE())"
				Set rs = connAdm.execute(strQuery)
				newId = CStr(rs("newId"))
				response.write(newId)
End If
Call disconnect
Call disconnectAdm
%>