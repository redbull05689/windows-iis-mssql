<%@Language="VBScript" CodePage = 65001 %>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
	Response.CharSet = "UTF-8"
	Response.CodePage = 65001

	server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentId = request.querystring("id")
revisionNumber = request.querystring("revisionNumber")
attachment = request.querystring("attachment")
removeUIDs = request.querystring("qs") ' if this equals "removeUIDs" it will remove the atom ids
stepNumber = ""
experimentType = 1
If canViewExperiment(1,experimentId,session("userId")) Or session("userId") = "2" then
	Call getconnected
	If revisionNumber = "" Then
		strQuery = "SELECT name, mrvData FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT name, mrvData FROM experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") 
	End if
	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		if not isNull(rec("mrvData")) then
			mrvData = Replace(rec("mrvData"),"\""","""")
			If revisionNumber = "" And ownsExperiment("1",experimentId,session("userId")) Then
				Set rec2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT experimentJSON FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
				rec2.open strQuery,conn,3,3
				If Not rec2.eof then
					Set experimentJSON = JSON.parse(rec2("experimentJSON"))
					If experimentJSON.exists("mrvData") then
						mrvData = experimentJSON.Get("mrvData")
					End if
				End If
				rec2.close
				Set rec2 = nothing
			End if
		End if
	End If

	' response.contenttype="application/octet-stream"
	

	If attachment = "true" then
		response.addheader "Content-Disposition", "attachment; " & "filename="""&cleanFileName(rec("name"))&"-reaction.mrv"""
		response.addheader "Content-Type","chemical/x-chemaxon-marvinfile"
	Else
		response.addheader "Content-Type","application/octet-stream"
	End if

	'Response.AddHeader "Content-Length", Len(cdxData)
	

	'send a blank cdx file if there is no cdx data 
	If Len(mrvData) = 0 Then
		mrvData = ""
	End If

	if removeUIDs = "removeUIDs" then
		Set objRegEx = CreateObject("VBScript.RegExp")
		objRegEx.Global = True   
		objRegEx.IgnoreCase = True
		objRegEx.Pattern = "<scalar[^>]+uid[^>]+>[^<]+</scalar>"
		mrvData = objRegEx.Replace(mrvData, "")
	end if
	response.write(mrvData)
End if
%>