<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%server.scripttimeout=600%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
uploadRootRoot = getCompanySpecificSingleAppConfigSetting("fileUploadRootFolder", session("companyId"))
'list experiments without pdf versions

if session("email") = "support@arxspan.com" then

	if request.form("listSubmit") <> "" Then
		Call getconnected
		types = Split("chem,bio,free,anal",",")

		count = 0
		For i = 0 To UBound(types)
			thisType = types(i)
			Select Case thisType
				case "chem"
					experimentsTableName = "experiments"
					experimentType = 1
					experimentPage = session("expPage")
				case "bio"
					experimentsTableName = "bioExperiments"
					experimentType = 2
					experimentPage = "bio-experiment.asp"
				case "free"
					experimentsTableName = "freeExperiments"
					experimentType = 3
					experimentPage = "free-experiment.asp"
				case "anal"
					experimentsTableName = "analExperiments"
					experimentType = 4
					experimentPage = "anal-experiment.asp"
			End Select
			Set rec = server.CreateObject("ADODB.RecordSet")
			'get attachments from the appropriate table for this company where the experiment has not been deleted.
			strQuery = "SELECT * FROM "&experimentsTableName&" WHERE userId in (SELECT id FROM users WHERE companyId="&SQLClean(session("companyId"),"N","S")&") and id in (SELECT experimentId FROM notebookIndex WHERE visible=1 and typeId="&SQLClean(experimentType,"N","S")&") ORDER BY id"
			rec.open strQuery,conn,0,-1
			Do While Not rec.eof
				filePath = uploadRootRoot&"\"&getCompanyIdByUser(rec("userId"))&"\"&rec("userId")&"\"&rec("id")&"\"&rec("revisionNumber")&"\"&thisType&"\sign.pdf"
				dim fs
				set fs=Server.CreateObject("Scripting.FileSystemObject")
				If Not fs.fileExists(filepath) Then
					count = count + 1
					%>
					<%=count%>. <a href="<%=mainAppPath%>/<%=experimentPage%>?id=<%=rec("id")%>"> <%=rec("id")%>&nbsp;<%=filepath%></a><br/>
					<%
				End if
				set fs=nothing
				rec.movenext
			Loop
			rec.close
			Set rec = nothing
		next
		Call disconnect
	end if
%>
	<form action="listMissingPDFs.asp" method="POST">
		<input type="submit" name="listSubmit" value="LIST">
	</form>
<%
end if
%>