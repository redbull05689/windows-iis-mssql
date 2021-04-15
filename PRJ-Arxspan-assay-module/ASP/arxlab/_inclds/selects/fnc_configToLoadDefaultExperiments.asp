

<%
    ' fnc to get variable that checks whether to use default exp types or not
    function configsForExperimentTypes ()

        set defaultValues = JSON.parse("[]")
        Set nRec = server.CreateObject("ADODB.RecordSet")
        strQuery = "SELECT useDefaultExperimentTypes FROM companySettings WHERE companyId="&SQLClean(session("companyId"),"T","S")
        nRec.open strQuery,conn,3,3

        Do While Not nRec.eof
            useDefaultExperimentTypes = nRec("useDefaultExperimentTypes")
                Set defaultExperimentObject = JSON.parse("{}")

                    defaultExperimentObject.set "useDefaultExperimentTypes", useDefaultExperimentTypes
                    defaultValues.push(defaultExperimentObject)
                nRec.movenext
        Loop
        nrec.close
        configsForExperimentTypes = JSON.stringify(defaultValues)
    End function
%>
    
