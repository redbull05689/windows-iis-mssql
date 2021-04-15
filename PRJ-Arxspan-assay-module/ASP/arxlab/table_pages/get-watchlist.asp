<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT e.id, " &_
            "e.name, " &_
	        "e.status, " &_
	        "e.type, " &_
	        "e.firstName + ' ' + e.lastName AS creator, " &_
	        "e.dateSubmitted, " &_
	        "e.experimentId, " &_
            "e.typeId, " &_
            "e.userExperimentName, " &_
			"e.requestTypeId, " &_
	        "(SELECT COUNT(*) FROM noteAddedNotifications WHERE experimentType=e.typeId AND experimentId=e.experimentId AND userId=e.userId AND (dismissed=0 or dismissed is null)) AS notificationCount, " &_
            "(SELECT COUNT(*) FROM attachmentAddedNotifications WHERE experimentType=e.typeId AND experimentId=e.experimentId AND userId=e.userId AND (dismissed=0 or dismissed is null)) AS attachmentCount, " &_
            "(SELECT COUNT(*) FROM experimentSavedNotifications WHERE experimentType=e.typeId AND experimentId=e.experimentId AND userId=e.userId AND (dismissed=0 or dismissed is null)) AS saveCount, " &_
            "(SELECT COUNT(*) FROM commentNotifications WHERE experimentType=e.typeId AND experimentId=e.experimentId AND userId=e.userId AND (dismissed=0 or dismissed is null)) AS commentCount " &_
           "FROM experimentFavoritesView e WHERE userId = {uId} AND visible=1 ORDER BY id DESC; "
strQuery = Replace(strQuery, "{uId}", SQLClean(session("userId"),"N","S"))
rec.open strQuery,conn

Set experimentTypeMap = JSON.Parse("{}")

Do While Not rec.eof
	If Not experimentTypeMap.Exists(CStr(rec("typeId"))) Then
		prefix = GetPrefix(rec("typeId"))
		
		Set thisType = JSON.Parse("{}")
		thisType.Set "prefix", prefix
		thisType.Set "expView", GetExperimentView(prefix)
		thisType.Set "page", GetExperimentPage(prefix)
		
		experimentTypeMap.Set CStr(rec("typeId")), thisType
	End If
	
	Set thisConfig = experimentTypeMap.Get(CStr(rec("typeId")))
	prefix = thisConfig.Get("prefix")
	expView = thisConfig.Get("expView")
	eType = GetFullExpType(rec("typeId"), rec("requestTypeId"))
	
    name = rec("name")
    status = rec("status")
    expId = rec("experimentId")
    typeId = rec("typeId")    
    creator = rec("creator")
    created = rec("dateSubmitted")
    saved = rec("saveCount")
    notes = rec("notificationCount")
    attachments = rec("attachmentCount")
    comments = rec("commentCount")
    rowId = rec("id")
    userExpName = rec("userExperimentName")
    
	expPage = thisConfig.Get("page")
    expPage = expPage & "?id=" & expId

    response.write("<a href=" & mainAppPath & "/" & expPage & "> " & name & "</a><br><i>" & userExpName & "</i>:::" &_
                   status & ":::" &_
                   eType & ":::" &_
                   creator & ":::" &_
                   created & ":::" &_
                   saved & ":::" &_
                   notes & ":::" &_
                   attachments & ":::" &_
                   comments & ":::" &_
                   "<a href='javascript:void(0);' onclick='deleteWatchlistItem(" & rowId & ")'> <img src='" & mainAppPath & "/images/cross_2_1x.png' class='png' height='12' width='12' border='0'></a>:::" &_
                   expId & ";;;")
	rec.movenext
loop
rec.close
%>