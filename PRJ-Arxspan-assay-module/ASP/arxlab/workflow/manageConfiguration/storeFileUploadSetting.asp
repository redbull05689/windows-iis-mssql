<!-- #include virtual="/_inclds/sessionInit.asp" -->

<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->

<%
    companyId = request.queryString("companyId")
    userId = request.querystring("userId")
    fileUploadSetting = request.queryString("fileUploadSetting")

    if fileUploadSetting <> "" and fileUploadSetting <> "Before" and fileUploadSetting <> "After" and fileUploadSetting <> "Delete" then
        response.write("Error")
    else

        strQuery = "UPDATE users " &_
                    "SET workflowFileUploadSetting=" & SQLClean(fileUploadSetting, "T", "S") & " " &_
                    "WHERE companyId=" & SQLClean(companyId, "N", "S") & " " &_
                    "AND id=" & SQLClean(userId, "N", "S")
        
        Set rec = server.CreateObject("ADODB.RecordSet")
        rec.open strQuery, connAdm, 3, 3
        response.write("Success")
    end if

%>