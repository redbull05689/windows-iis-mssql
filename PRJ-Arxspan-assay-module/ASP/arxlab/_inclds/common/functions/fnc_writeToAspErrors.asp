<%
    function writeToAspErrors(scriptName, description, lineNumber)        
        Call getconnectedadm
        strQuery = "INSERT into aspErrors(dateSubmittedServer,userId,scriptName,description,lineNumber) output inserted.id as newId values(GETDATE(),"&SQLClean(session("userId"),"N","S")&","&SQLClean(scriptName,"T","S")&","&SQLClean(description,"T","S")&","&SQLClean(lineNumber,"N","S")&");"
        Set rs = connAdm.execute(strQuery)
        writeToAspErrors = CStr(rs("newId"))
        Call disconnectadm
    end function
%>