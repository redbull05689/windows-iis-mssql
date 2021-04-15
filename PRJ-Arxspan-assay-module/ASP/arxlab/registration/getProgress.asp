<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
fid = request.querystring("fid")
bulkRegEndpointUrl = getCompanySpecificSingleAppConfigSetting("bulkRegEndpointUrl", session("companyId"))
Call getconnectedJchemReg

set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT newUploadId FROM sdImports WHERE fid="&SQLClean(fid,"T","S")
rec.open strQuery,jchemRegConn,3,3
if not rec.eof then
	Set http = CreateObject("MSXML2.ServerXMLHTTP")
	http.open "GET", bulkRegEndpointUrl&"/getUploadStatus?uploadId="&rec("newUploadId"), True
	
	http.SetTimeouts 180000,180000,180000,180000
	' ignore ssl cert errors
	http.setOption 2, 13056
	http.send
	http.waitForResponse(180)
	
	Set retVal = JSON.Parse(http.responseText)
	If retVal.Exists("items") And retVal.Exists("status") Then
		Set items = retVal.Get("items")
		If items.Exists("percentComplete") And items.Exists("errorCount") And items.Exists("numDuplicates") And items.Exists("status") Then
%>
[<%=items.Get("percentComplete")%>,"<%=replace(retVal.Get("status"),"'","\'")%>",<%=items.Get("numDuplicates")%>,<%=items.Get("rowCount")%>,<%=items.Get("recordsProcessed")%>,<%=items.Get("errorCount")%>]
<%
		End If
	End If
end if
rec.close
Set rec = Nothing
Call disconnectJchemReg
%>