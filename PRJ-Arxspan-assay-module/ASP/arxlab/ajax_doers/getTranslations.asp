
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/__whichServer.asp"-->
 
<%
    set outJson = JSON.parse("{}")
    set labels = Request.Form("labels")
    labels = Split(labels,",")
    For Each label in labels
        if (IsEmpty(languageJSON.Get(label))) Then
            outJson.set label, ("Non-Existent label") 
        Else 
            outJson.set label, languageJSON.Get(label)
        End if
    Next
    response.write(JSON.stringify(outJson))
    
%>