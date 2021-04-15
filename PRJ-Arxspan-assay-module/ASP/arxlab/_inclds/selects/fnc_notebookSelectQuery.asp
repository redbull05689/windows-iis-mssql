
<%
    ' function for getting notebooks and making them into json
   function getNotebooks() 

        Set notebookRec = server.CreateObject("ADODB.RecordSet")
        strQuery = "SELECT DISTINCT notebookId,userId,name,visible,lastViewed,description,fullName FROM allNotebookPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and ((accepted=1 and canWrite=1) or (accepted is null and canWrite=1) or canWrite is null) order by lastViewed DESC"
        notebookRec.open strQuery,conn,0,-1
        
        Set notebookList = JSON.parse("[]")
        
        Do While Not notebookRec.eof
            notebookId = notebookRec("notebookId")
            name = notebookRec("name")

            Set notebookObj = JSON.parse("{}")

                notebookObj.set "notebookId", notebookId
                notebookObj.set "name", name
                notebookList.push(notebookObj)

            notebookRec.movenext
        Loop
        notebookRec.close
        getNotebooks = JSON.stringify(notebookList)
    End function 
%>