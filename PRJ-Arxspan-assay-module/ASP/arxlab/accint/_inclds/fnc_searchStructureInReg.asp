<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
    function searchStructureInReg(structure)
        set returnJson = JSON.parse("{}")
        arr = getLocalRegNumber(structure,false)
        cdId = arr(0)
        localRegNumber = arr(1)

        returnJson.set "localRegNumber", localRegNumber

        If localRegNumber <> False Then
            set notebookNames = JSON.parse("[]")
            Set rec2 = server.CreateObject("ADODB.RecordSet")
            strQuery = "SELECT DISTINCT notebookId FROM accMols WHERE localRegNumber="&SQLClean(localRegNumber,"T","S")
            rec2.open strQuery,jchemRegConn,3,3
            Set nbRec = Server.CreateObject("ADODB.RecordSet")
            Do While Not rec2.eof
                nbQuery = "SELECT name FROM notebooks WHERE id="&rec2("notebookId")
                nbRec.open nbQuery, conn,3,3
                If Not nbRec.eof Then
                    notebookNames.push(CSTR(nbRec("name")))
                End If
                nbRec.close
                rec2.movenext
            Loop
            Set nbRec = Nothing
            rec2.close
            Set rec2 = nothing
        End if

        returnJson.set "notebookNames", notebookNames
        searchStructureInReg = JSON.stringify(returnJson)
    end function
%>