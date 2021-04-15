<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/selects/fnc_notebookSelectQuery.asp" -->

<%
    ' sends out the result of calling the getNotebooks fnc within the notebookSelectQuery fnc
        Set defaultSessionNotebook = JSON.parse(getNotebooks())
        
        Set sessionNotebook = JSON.parse("[]")

        For Each notebook in defaultSessionNotebook
            if notebook.get("notebookId") = session("defaultNotebookId") OR notebook.get("notebookId") = CStr(session("defaultNotebookId")) Then 
            sessionNotebook.push(notebook)
            End If
            Next

    Response.write(JSON.stringify(sessionNotebook))
    Response.end
%>