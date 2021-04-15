<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<!-- #include file="./returnImageFile.asp"-->
<%
experimentId = request.querystring("experimentId")
experimentType = 1
If canViewExperiment(1,experimentId,session("userId")) then
	Call getconnected
	If revisionNumber = "" Then
		strQuery = "SELECT userId,revisionNumber,id FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT userId,revisionNumber,id FROM experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") 
	End If
	
	Set iRec = server.CreateObject("ADODB.RecordSet")
	iRec.open strQuery,conn,adOpenStatic,adLockReadOnly
	filename = "prods.gif"
	filepath = uploadRootRoot & "\" & getCompanyIdByUser(iRec("userId")) & "\"& iRec("userId") &"\" & experimentId & "\" & iRec("revisionNumber") & "\chem\chemData\"
	iRec.close()
	Set iRec = nothing
	
	response.contenttype="image/gif"
	response.addheader "ContentType","image/gif"
	response.addheader "Content-Disposition", "inline; " & "filename=chem-"&experimentId&".gif"

	Call returnImageFile(filepath, filename, server.mapPath(mainAppPath)&"/images/", "blank.gif")
End If
%>