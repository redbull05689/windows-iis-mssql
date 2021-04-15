<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
server.scriptTimeout=3600
' Needs isApiPage=True so that sendToFT can call this using REST
isApiPage=True
%>
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
response.buffer = false
response.charset = "UTF-8"
response.codePage = 65001
regEnabled=True
If request.servervariables("REMOTE_ADDR") <> "8.20.189.170" And request.servervariables("REMOTE_ADDR") <> "8.20.189.168" And request.servervariables("REMOTE_ADDR") <> "8.20.189.169" And request.servervariables("REMOTE_ADDR") <> "8.20.189.188" And request.servervariables("REMOTE_ADDR") <> "8.20.189.16" then
	response.redirect("/login.asp")
End if
session("companyId") = request.querystring("companyId")
If session("companyId") = "62" Then
	session("overrideDB")="BROAD"
End if
session("userId") = request.querystring("userId")
session("hasReg") = True
regId = request.querystring("regId")
sendFile = request.querystring("sendFile")
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/common/asp/lib_JChem.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/fnc_sendProteinToSearchTool.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/lib_reg.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
call getconnectedAdm
hideLoginNotification = true
loginUser(session("userId"))
Set http = server.CreateObject("MSXML2.ServerXMLHTTP")
http.setOption 2, 13056
Call getConnectedJchemReg
regIds = Split(regId,",")
For qq = 0 To UBound(regIds)
	regId = regIds(qq)
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM "&regMoleculesTable&" WHERE reg_id="&SQLClean(regId,"T","S")&" OR reg_id="&SQLClean(regId&"-0","T","S")&" OR reg_id="&SQLClean(regId&"-00","T","S")&" OR reg_id="&SQLClean(regId&"-000","T","S")&" OR reg_id="&SQLClean(regId&"-0000","T","S")
	rec.open strQuery,jchemRegConn,0,-1
	If Not rec.eof Then
		If sendFile = "1" Then
			a = sendProteinToSearchTool(rec("cd_id"),true,true)	
			response.write("success")
		else
			Set a = sendProteinToSearchTool(rec("cd_id"),false,true)
			response.write(JSON.stringify(a))
		End if
	End If
	rec.close
	Set rec = nothing
next
call disconnect	
call disconnectadm
Call disconnectJchemReg
%>
<%Session.Contents.RemoveAll()%>
<%session.abandon()%>