<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"--><%
server.scripttimeout = 100000
logTableName = getLogTableName()
set groups = JSON.parse(request.form("data"))
showInactive = request.form("inactive")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT " &_
	   "a.id, " &_
       "a.fullName, " &_
	   "a.email, " &_
       "a.lastActivityTime, " &_
       "(SELECT TOP 1 CAST(dateSubmitted AS DATE) FROM allExperiments_history n WITH (NOLOCK) WHERE n.statusId = 6 AND a.id = n.userId AND n.companyId = {companyId} ORDER BY dateSubmitted DESC) AS lastWitness, " &_
       "(SELECT COUNT(id) FROM allExperiments n WITH (NOLOCK) WHERE a.id = n.userId AND n.companyId = {companyId} AND n.visible = 1) AS numExperiments, " &_
       "(SELECT COUNT(id) FROM allExperiments n WITH (NOLOCK) WHERE a.id = n.userId AND n.companyId = {companyId} AND n.visible = 1 AND statusId = 6) AS numWitnessed, " &_
       "(SELECT COUNT(id) FROM allExperiments n WITH (NOLOCK) WHERE a.id = n.userId AND n.companyId = {companyId} AND n.visible = 1 AND statusId = 5) AS numSigned, " &_
       "(SELECT COUNT(id) FROM allExperiments n WITH (NOLOCK) WHERE a.id = n.userId AND n.companyId = {companyId} AND n.visible = 1 AND statusId = 2) AS numSaved, " &_
       "(SELECT COUNT(id) FROM allExperiments n WITH (NOLOCK) WHERE a.id = n.userId AND n.companyId = {companyId} AND n.visible = 1 AND statusId = 1) AS numCreated, " &_
       "a.enabled " &_
"FROM usersView a WITH (NOLOCK)" &_
"WHERE a.companyId = {companyId} " &_
"{inactiveQuery} " &_
"AND a.email LIKE '%@{filterData}%'" &_
"AND a.email <> 'support@arxspan.com' "

strQuery = Replace(strQuery, "{companyId}", session("companyId"))
strQuery = Replace(strQuery, "{filterData}", session("opReportFilter"))

inactiveQuery = ""

if not showInactive then
    inactiveQuery = "AND a.enabled = 1"
end if

strQuery = Replace(strQuery, "{inactiveQuery}", inactiveQuery)

if groups.length > 0 then
    groupQuery = "AND a.id IN " &_
                    "(SELECT userId " &_
                    "FROM groupMembers " &_
                    "WHERE groupId IN ({groupIds}))"

    groupQuery = Replace(groupQuery, "{groupIds}", groups.join(","))
    strQuery = strQuery & groupQuery    
end if

rec.open strQuery,conn,0,-1
Do While Not rec.eof
	userId = rec("id")
	userName = rec("fullName")
	lastActivityTime = rec("lastActivityTime")
	lastActivityTime = IIF(IsNull(lastActivityTime), "N/A", lastActivityTime)
	lastWitness = rec("lastWitness")
	lastWitness = IIF(IsNull(lastWitness), "N/A", lastWitness)
	numExperiments = rec("numExperiments")
	numWitnessed = rec("numWitnessed")
	numSigned = rec("numSigned")
	numSaved = rec("numSaved")
	numCreated = rec("numCreated")
	userEmail = rec("email")
    enabled = rec("enabled")

    response.write(userId & ":::" &_
                    userName & ":::" &_
                    "<a href=" & mainAppPath & "/reporting/report_activity_detail.asp?id=" & userId & " title='" & userEmail &"'>" & userName &"</a>" & ":::" &_
                    lastActivityTime & ":::" &_
                    lastWitness & ":::" &_
                    numExperiments & ":::" &_
                    numWitnessed & ":::" &_
                    numSigned & ":::" &_
                    numSaved & ":::" &_
                    numCreated & ":::" &_
                    enabled & ";;;")
	rec.movenext
loop
rec.close
%>