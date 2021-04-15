<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../globals.asp"-->

<%

' Make a request to the workflow DB to check if this user is in the co-authors field of the experiment.
expId = request.form("id")

workflowDB = "[ARXSPAN-ORDERS-" & whichServer & "].dbo."

strQuery = "SELECT DISTINCT " &_
            "u2.id AS userId from " &_
            "custExperiments_history e " &_
            "JOIN " & workflowDB & "requestHistory r ON e.requestRevisionNumber=r.id " &_
            "JOIN users u2 ON u2.id=r.userId " &_
            "WHERE experimentId=" & expId
Set rec = server.CreateObject("ADODB.RecordSet")
rec.open strQuery, connadm, 3, 3

do while not rec.eof
    response.write(rec("userId") & ",")
    rec.movenext
loop
rec.close
Set rec = Nothing
response.end

%>