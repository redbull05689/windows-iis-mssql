<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/selects/fnc_projectSelectQuery.asp" -->

<%
    ' sends out the result of calling the getProjects fnc within the projectSelectQuery fnc
        Set defaultSessionProject = JSON.parse(getProjects())
        
        Set sessionProject = JSON.parse("[]")

        For Each project in defaultSessionProject
            if project.get("id") = CStr(session("defaultProjectId")) OR project.get("id") = session("defaultProjectId") Then 
            sessionProject.push(project)
            End If
            Next
            
        Response.write(JSON.stringify(sessionProject))
        Response.end
%>  