<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
hungSaveSerial = -1
'hasAttachments = experimentHasAttachments(experimentType,experimentId,revisionId)
hasAttachments = True
hasNotes = experimentHasNotes(experimentType,experimentId,revisionId)
hasEMData = experimentHasElementalMachinesData(experimentType, experimentId, revisionId)
canRead = canReadNotebook(notebookId,session("userId"))
canWrite = canWriteNotebook(notebookId)
notebookOwner = ownsNotebook(notebookId)
ownsExp = ownsExperiment(experimentType,experimentId,session("userId"))
notebookVisible = isNotebookVisible(notebookId)
experimentVisible = isExperimentVisible(experimentType,request.querystring("id"))

if experimentType = "5" then
	callingMethod = "getExperimentPermissions"
	isCoAuthor = checkCoAuthors(experimentId, experimentType, callingMethod)
	canWrite = isCoAuthor or ownsExp
	%>
		<!-- #include file="../../cust/asp/check-existing-draft.asp"-->	
	<%
eLsE
	isDraftAuthor = True
eNd If

ownsExp = ownsExp or isCoAuthor

Select Case experimentType
	Case "1"
		logType = "2"
	Case "2"
		logType = "3"
	Case "3"
		logType = "4"
	Case "4"
		logType = "6"
End select

a = logAction(logType,experimentId,"",29)

isExperimentPage = True

Call getconnectedadm
If ownsExp And request.querystring("revisionId") = "" then
%>
<!-- #include file="getExperimentJSON.asp"-->
<%
	strQuery = "INSERT into hungExperiments(theDate,userId,experimentId,experimentType,revisionNumber,serial,firstTimeout,secondTimeout,ipAddress,uaString,theForm) output inserted.id as newId values(GETDATE()," &_
					SQLClean(session("userId"),"N","S") & "," &_
					SQLClean(experimentId,"N","S") & "," &_
					SQLClean(experimentType,"N","S") & "," &_
					SQLClean(request.querystring("revisionId"),"N","S") & "," &_
					SQLClean(hungSaveSerial,"T","S") & "," &_
					SQLClean(0,"N","S") & "," &_
					SQLClean(0,"N","S") & "," &_
					SQLClean(request.servervariables("REMOTE_ADDR"),"T","S") & "," &_
					SQLClean(request.servervariables("HTTP_USER_AGENT"),"T","S") & "," &_
					SQLClean("","T","S") & ")"
	Set rs = connAdm.execute(strQuery)
	hungSaveSerial = CStr(rs("newId"))
	connAdm.execute("UPDATE hungExperiments SET serial="&SQLClean(hungSaveSerial,"T","S")&" WHERE id="&SQLClean(hungSaveSerial,"N","S"))
	experimentJSON.Set "hungSaveSerial", hungSaveSerial
Else
	Set experimentJSON = JSON.parse("{}")
End If
%>
