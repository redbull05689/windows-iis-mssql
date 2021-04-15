<%@Language="VBScript" CodePage = 65001 %>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<% 
	Response.CharSet = "UTF-8"
	Response.CodePage = 65001

	server.scriptTimeout = 10000
%>
<!-- #include file="../../../_inclds/globals.asp"-->
<%
Randomize
experimentId = request.querystring("id")
revisionNumber = request.querystring("revisionNumber")
attachment = request.querystring("attachment")
removeUIDs = request.querystring("qs") ' if this equals "removeUIDs" it will remove the atom ids
stepNumber = ""
experimentType = 1
If canViewExperiment(1,experimentId,session("userId")) Or session("userId") = "2" then
	Call getconnected
	If revisionNumber = "" Then
		strQuery = "SELECT mrvData FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
	Else
		strQuery = "SELECT mrvData FROM experiments_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber=" & SQLClean(revisionNumber,"N","S") 
	End if
    Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery,conn,3,3
	If Not rec.eof Then
		if not isNull(rec("mrvData")) then
			if Trim(rec("mrvData")) <> "" then
            	Response.Redirect "/arxlab/experiments/ajax/load/getMRV.asp?id=" & experimentId & "&revisionNumber=" & revisionNumber & "&attachment=" & attachment & "&qs=" & removeUIDs & "&rand=" & Rnd
			end if
        end if
    end if
end if
' fallback
response.Redirect "/arxlab/experiments/ajax/load/getCDX.asp?id=" & experimentId & "&revisionNumber=" & revisionNumber & "&attachment=" & attachment & "&qs=" & removeUIDs & "&rand=" & Rnd
%>