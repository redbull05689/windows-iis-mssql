<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
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
	iRec.open strQuery,conn,3,3
	filepath = uploadRootRoot & "\" & getCompanyIdByUser(iRec("userId")) & "\"& iRec("userId") &"\" & experimentId & "\" & iRec("revisionNumber") & "\chem\chemData\prods_big.gif"
	response.contenttype="image/gif"
	response.addheader "ContentType","image/gif"
	response.addheader "Content-Disposition", "inline; " & "filename=chem-"&experimentId&".gif"
	If filepath <> "" Then
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
			Set adoStream = CreateObject("ADODB.Stream")  
			adoStream.Open()  
			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)  
			Response.BinaryWrite adoStream.Read()  
			adoStream.Close: Set adoStream = Nothing  
			Response.End  
		else
			filepath = server.mapPath(mainAppPath)&"\images\blank.gif"
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			if fs.FileExists(filepath) Then
				Set adoStream = CreateObject("ADODB.Stream")  
				adoStream.Open()  
				adoStream.Type = 1  
				adoStream.LoadFromFile(filepath)  
				Response.BinaryWrite adoStream.Read()  
				adoStream.Close: Set adoStream = Nothing  
				Response.End
			End if
		End if
	End if
End if
%>