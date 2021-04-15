<!-- #include virtual="/_inclds/sessionInit.asp" -->

<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%
    companyId = request.queryString("companyId")
    userId = request.querystring("userId")

    strQuery = "SELECT workflowFileUploadSetting " &_
                "FROM usersView " &_
                "WHERE companyId=" & SQLClean(companyId, "N", "S") & " " &_
                "AND id=" & SQLClean(userId, "N", "S")
    
    Set rec = server.CreateObject("ADODB.RecordSet")
    rec.open strQuery, connAdm, 3, 3
    
    if not rec.eof then
        response.write(rec("workflowFileUploadSetting"))
    end if

%>