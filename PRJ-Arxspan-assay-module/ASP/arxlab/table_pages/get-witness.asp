<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
    server.scriptTimeout = 600
%>
<!-- #include file="../_inclds/globals.asp"-->
<%
requests = request.querystring("requests")

Set rec = server.CreateObject("ADODB.RecordSet")

strQuery = "SELECT wr.name AS name, " &_
    "wr.experimentId as experimentId, " &_
    "wr.experimentTypeId as experimentTypeId, " &_
    "wr.experimentOwner as experimentOwner, " &_
    "h.dateSubmittedServer AS dateSubmittedServer, " &_
    "wr.requestTypeId AS requestTypeId " &_
"FROM witnessRequestsView as wr " &_
"LEFT JOIN allExperiments_history h " &_
    "ON wr.experimentId=h.legacyId " &_
    "AND wr.experimentTypeId=h.experimentType " &_
"WHERE wr.requesteeId={uId} "

if requests <> "" then
    strQuery = strQuery & "AND h.statusId=5 " &_
                            "AND h.revisionNumber = (SELECT MAX(revisionNumber) FROM allExperiments_history WHERE legacyId=h.legacyId AND experimentType=h.experimentType) " &_
                            "AND wr.accepted=0 " &_
                            "AND wr.denied=0 " &_
                            "AND not exists " &_
                                "(SELECT * " &_
                                "FROM witnessRequestsView " &_
                                "WHERE (accepted=1 or denied=1) " &_
                                "AND experimentId=wr.experimentId " &_
                                "AND experimentTypeId=wr.experimentTypeId) "
else
    strQuery = strQuery & "AND h.statusId=6 " &_
                            "AND wr.accepted=1 "
end if

strQuery = strQuery & "ORDER BY dateSubmittedServer DESC;"
strQuery = Replace(strQuery, "{uId}", SQLClean(session("userId"),"N","S"))
rec.open strQuery,conn,0,-1

Set experimentTypeMap = JSON.Parse("{}")
Set experimentRowList = JSON.Parse("[]")

Do While Not rec.eof
    Set experimentRow = JSON.parse("{}")

    name = rec("name")
    expId= rec("experimentId")
    typeId = rec("experimentTypeId")
    sharer = rec("experimentOwner")
    dateReq = rec("dateSubmittedServer")
    
    check = true
    if typeId = "5" then
        expRevision = getExperimentRevisionNumber(rec("experimentTypeId"),rec("experimentId"))
        check = checkIfAllSigned(rec("experimentId"), rec("experimentTypeId"), expRevision)
    end if

    if check then
		If Not experimentTypeMap.Exists(CStr(rec("experimentTypeId"))) Then
			prefix = GetPrefix(rec("experimentTypeId"))
			
			Set thisType = JSON.Parse("{}")
			thisType.Set "prefix", prefix
			thisType.Set "page", GetExperimentPage(prefix)
			
			experimentTypeMap.Set CStr(rec("experimentTypeId")), thisType
		End If
		
		Set thisConfig = experimentTypeMap.Get(CStr(rec("experimentTypeId")))
		prefix = thisConfig.Get("prefix")
		expPage = thisConfig.Get("page")
        expType = GetFullExpType(typeId, rec("requestTypeId"))

        expPage = expPage & "?id=" & expId
        
        experimentRow.set "name", "<a href=" & mainAppPath & "/" & expPage & "> " & name & "</a>"
        experimentRow.set "type", expType
        experimentRow.set "sharer", sharer
        experimentRow.set "date", CSTR(dateReq)
        experimentRow.set "expId", expId
        experimentRowList.push(experimentRow)
    end if
	rec.movenext
loop
rec.close

response.write JSON.stringify(experimentRowList)
response.end
%>