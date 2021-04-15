<!-- #include virtual="/_inclds/sessionInit.asp" -->

<%isAjax=true%>
<!-- #include file="../../_inclds/globals.asp"-->

<%

    set data = JSON.parse(request.form("data"))

	Call getConnectedAdm
    Set rec = server.CreateObject("ADODB.RecordSet")
    'strQuery = "UPDATE elementalMachinesData " &_
    '"(id, annotation) " &_
    '"VALUES " &data.get("data")

    'rec.open strQuery, connAdm, 3, 3
    
    for each key in data.keys()
        strQuery = "UPDATE elementalMachinesData " &_
        "SET annotation= " & SQLClean(data.get(key), "T", "S") & " " &_
        "WHERE id= " & key

        rec.open strQuery, connAdm, 3, 3
        
    next
    
	Call disconnectAdm

%>