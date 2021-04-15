<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->

<%
    reqId = request.form("reqId")
    reqFieldId = request.form("reqFieldId")
    workflowDB = "[ARXSPAN-ORDERS-" & whichServer & "].dbo."

    valQuery = "SELECT dropDownValue FROM " & workflowDB & "requestFieldValues WHERE requestFieldsId=" & reqFieldId
    Set valRec = server.CreateObject("ADODB.RecordSet")

    valRec.open valQuery, connAdm, 3, 3

    if not valRec.eof then
        response.write valRec("dropDownValue")
    end if

%>