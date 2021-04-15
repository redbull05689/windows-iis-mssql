<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<%

    requestId = request.querystring("requestId")

    requestUrl = "/workflow/viewIndividualRequest.asp?requestId=" & requestId
    strQuery = "SELECT id FROM custExperiments WHERE requestId=" & requestId

    Set custExpRec = server.CreateObject("ADODB.RecordSet")
    custExpRec.open strQuery, connadm, 3, 3
    
    if not custExpRec.eof then
        expId = custExpRec("id")
        requestUrl = "/cust-experiment.asp?id=" & expId
    end if

    custExpRec.close
    Set custExpRec = Nothing

    redirectUrl = mainAppPath & requestUrl
%>

<script>
    window.location = "<%=redirectUrl%>"
</script>