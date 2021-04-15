<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<%Server.scripttimeout=180000%>
<%response.buffer = false%>
<%isApiPage=True%>
<!-- #include file="../_inclds/backup_and_pdf/functions/fnc_getCSXML.asp"-->
<!-- #include file="../_inclds/globals.asp"-->
<%
Set jsonReq = JSON.Parse(request.form)

errMsg = ""
If Not jsonReq.Exists("experimentId") Then
    errMsg = errMsg & "experimentId is a required parameter"
End If

If Not jsonReq.Exists("experimentType") Then
    If errMsg <> "" Then
        errMsg = errMsg & "; "
    End If
    errMsg = errMsg & "experimentType is a required parameter"
End If

If errMsg <> "" Then
    response.write(errMsg)
    response.end()
End If

hasAccess = False
session("companyId") = ""
remoteIp = request.servervariables("REMOTE_ADDR")
If whichServer = "PROD" And (remoteIp = "8.20.189.20" Or remoteIp = "8.20.189.188") Then
    hasAccess = True
ElseIf whichServer = "BETA" And (remoteIp = "8.20.189.12" Or remoteIp = "8.20.189.170") Then
    hasAccess = True
End If

If hasAccess = True Then
	Set xmlRec = server.CreateObject("ADODB.Recordset")
	strQuery = "SELECT companyId from allExperiments WHERE legacyId=" & SQLClean(jsonReq.Get("experimentId"),"N","S") & " AND experimentType=" & SQLClean(jsonReq.Get("experimentType"),"N","S")
    xmlRec.open strQuery,conn,3,3
	
	If Not xmlRec.eof Then
		session("companyId") = xmlRec("companyId")
	End If
	xmlRec.close
    Set xmlRec = Nothing
Else
    data = request.form
    %>
    <!-- #include virtual="/arxlab/_inclds/globals_apis.asp" -->
    <%
End If

If session("companyId") <> "" Then
	response.charset = "UTF-8"
	response.codePage = 65001
	
	Set xmlRec = server.CreateObject("ADODB.Recordset")
	strQuery = "SELECT id from USERS where email='support@arxspan.com' AND companyId="&session("companyId")
	xmlRec.open strQuery,conn,3,3
	
	If Not xmlRec.eof Then
		session("userId") = xmlRec("id")
	End If
	xmlRec.close
	Set xmlRec = Nothing

	setJWT session("userId"), session("companyId")
	session.Save()
	Call getCSXML(session("companyId"),jsonReq.Get("experimentType"),jsonReq.Get("experimentId"))
End If
%>