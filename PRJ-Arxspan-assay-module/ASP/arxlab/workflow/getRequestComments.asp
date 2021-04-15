<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../_inclds/connection.asp"-->

<%
    expId = request.form("expId")
    expType = request.form("expType")
    reqField = request.form("reqField")
    getConnectedAdm
    strQuery = "select u.firstName + ' ' + u.lastName AS userName, ec.dateSubmitted, ec.comment from experimentComments ec join users u on ec.userId = u.id WHERE ec.experimentId=" & expId & " AND ec.experimentType=" & expType & " AND ec.requestFieldId=" & reqField & " AND (ec.deleted IS null OR ec.deleted=0) ORDER BY ec.id DESC"
    resp = ""

    Set rec = server.CreateObject("ADODB.RecordSet")
    
    rec.open strQuery, connAdm, adOpenForwardOnly, adLockReadOnly
    do while not rec.eof
        userName = rec("userName")
        commentDate = rec("dateSubmitted")
        text = rec("comment")

        resp = resp & userName & ",,,,,"
        resp = resp & commentDate & ",,,,,"
        resp = resp & text & ",,,,,"
        resp = resp & "|||||"
        rec.movenext
    loop
    disconnectAdm
    response.write resp
%>