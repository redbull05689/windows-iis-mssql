<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/users/functions/fnc_sendNotification.asp"-->
<!-- #include virtual="arxlab/_inclds/globals.asp"-->

<%

UID = Request.Form("UID")
Title = Request.Form("Title")
Note = Request.Form("Note")
noteType = Request.Form("noteType")


a = sendNotification(UID,Title,Note,noteType)
response.write(Note)
%>