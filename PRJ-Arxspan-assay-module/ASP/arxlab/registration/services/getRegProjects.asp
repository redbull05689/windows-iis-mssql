<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
server.scriptTimeout=3600
' Needs isApiPage=True so that sendToFT can call this using REST
isApiPage=True
%>
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
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
<!-- #include virtual="/arxlab/_inclds/globals.asp" -->
<!-- #include file="../../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->
<!-- #include virtual="/arxlab/_inclds/common/asp/lib_JChem.asp" -->
<!-- #include virtual="/arxlab/registration/_inclds/lib_reg.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
call getconnectedAdm
cdIdList = Split(cdIds, ",")
Set projectJson = New JSONarray
Set rec = server.CreateObject("ADODB.RecordSet")

For i = 0 To UBound(cdIdList)
	cdId = cdIdList(i)
	parentCdId = -1
	
	regMoleculesTable = getCompanySpecificSingleAppConfigSetting("regMoleculesTable", session("companyId"))
	strQuery = "SELECT parent_cd_id FROM "&regMoleculesTable&" WHERE cd_id=" & SQLClean(cdId,"T","S")
	rec.open strQuery,jchemRegConn,0,-1
	If Not rec.eof Then
		parentCdId = rec("parent_cd_id")
	End If
	rec.close

	strQuery = "SELECT projectId FROM "&regMoleculesTable&" WHERE cd_id in (" & cdId & "," & parentCdId & ") AND projectId IS NOT NULL "
	rec.open strQuery,jchemRegConn,0,-1

	projectIdStr = ""
	Set projectIdJson = New JSONobject
	Do While Not rec.eof
		If IsNull(projectIdJson.value(rec("projectId"))) Then
			projectIdJson.Add rec("projectId"), 1
			
			If projectIdStr <> "" Then
				projectIdStr = projectIdStr & ","
			End If
			
			projectIdStr = projectIdStr & rec("projectId")
		End If
		rec.movenext
	Loop
	rec.close
	
	strQuery = "SELECT distinct projectId FROM linksProjectRegView where (cd_id="&SQLClean(cdId,"N","S")&" OR cd_id="&SQLClean(theParentCdId,"N","S")&") AND companyId="&SQLClean(session("companyId"),"N","S")
	rec.open strQuery,conn,0,-1
	Do While Not rec.eof
		If IsNull(projectIdJson.value(rec("projectId"))) Then
			projectIdJson.Add rec("projectId"), 1
			
			If projectIdStr <> "" Then
				projectIdStr = projectIdStr & ","
			End If
			
			projectIdStr = projectIdStr & rec("projectId")
		End If
		rec.movenext
	Loop
	rec.close
	
	If projectIdStr <> "" Then
		strQuery = "SELECT id, name FROM projects WHERE id in(" & SQLClean(projectIdStr,"N","S") & ")"
		rec.open strQuery,conn,0,-1
		Do While Not rec.eof
			Set thisJson = New JSONobject
			thisJson.Add "projectId", CStr(rec("id"))
			thisJson.Add "projectName", CStr(rec("name"))
			projectJson.Push thisJson
			rec.movenext
		Loop
		rec.close
	End If
Next

projectJson.write()
response.end()

Set rec = Nothing
call disconnect	
call disconnectadm
Call disconnectJchemReg
%>
<%Session.Contents.RemoveAll()%>
<%session.abandon()%>
