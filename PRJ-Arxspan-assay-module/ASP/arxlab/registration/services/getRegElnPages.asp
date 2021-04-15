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
cdIds = request.querystring("cdIds")
session("hasReg") = True
%>
<!-- #include virtual="/arxlab/_inclds/__whichServer.asp" -->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->
<!-- #include virtual="/arxlab/_inclds/common/asp/lib_JChem.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/lib_reg.asp" -->
<!-- #include file="../../_inclds/security/functions/fnc_getServerBaseUrl.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
elnJsonStr = "["

If cdIds <> "" Then
	call getconnectedAdm
	Set rec = server.CreateObject("ADODB.RecordSet")
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	strQuery = "SELECT reg_id FROM "&regMoleculesTable&" WHERE cd_id in (" & SQLClean(cdIds,"N","S") & ")"
	rec.open strQuery,jchemRegConn,0,-1
	
	Do While Not rec.eof
		If Len(elnJsonStr) > 1 Then
			elnJsonStr = elnJsonStr & ","
		End If
		
		thisVal = "{""" & rec("reg_id") & """:["
		strQuery = "SELECT experimentId, experimentType, name, details FROM experimentRegLinksView WHERE regNumber="&SQLClean(rec("reg_id"),"T","S")&" AND companyId="&SQLClean(session("companyId"),"N","S")
		rec2.open strQuery,conn,0,-1
		
		theseVals = ""
		Do While Not rec2.eof
			If theseVals <> "" Then
				theseVals = theseVals & ","
			End If
			
			expPage = ""
			Select Case rec2("experimentType")
				Case "1"
					expPage = "experiment.asp"
				Case "2"
					expPage = "bio-experiment.asp"
				Case "3"
					expPage = "free-experiment.asp"
				Case "4"
					expPage = "anal-experiment.asp"
			End Select
			
			If expPage <> "" Then
				experimentUrl = getServerBaseUrl()&mainAppPath&"/"&expPage&"?id="&rec2("experimentId")
				theseVals = theseVals & "{""experimentUrl"":"""&experimentUrl&""",""experimentName"":"""&rec2("name")&""",""experimentDescription"":"""&rec2("details")&"""}"
			End If
			
			rec2.movenext
		Loop
		rec2.close
		
		thisVal = thisVal & theseVals & "]}"
		elnJsonStr = elnJsonStr & thisVal
		rec.movenext
	Loop
	rec.close
	Set rec = Nothing
	Set rec2 = Nothing
	
	call disconnect	
	call disconnectadm
	Call disconnectJchemReg
End If

elnJsonStr = elnJsonStr & "]"
response.write(elnJsonStr)

session.Contents.RemoveAll()
session.abandon()
response.end()
%>
