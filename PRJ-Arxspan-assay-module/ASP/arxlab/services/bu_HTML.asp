<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.scripttimeout=180000%>
<%response.buffer = false%>
<%isApiPage=True%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/backup_and_pdf/functions/fnc_getExperimentHTML.asp"-->
<%
hasAccess = False
remoteIp = request.servervariables("REMOTE_ADDR")
If whichServer = "PROD" And (remoteIp = "8.20.189.20" Or remoteIp = "8.20.189.188") Then
    hasAccess = True
End If
If whichServer = "BETA" And (remoteIp = "8.20.189.12" Or remoteIp = "8.20.189.170") Then
    hasAccess = True
End If

If hasAccess = True Then
	response.write(getExperimentHTML(request.querystring("experimentId"),request.querystring("experimentType")))
End if
%>