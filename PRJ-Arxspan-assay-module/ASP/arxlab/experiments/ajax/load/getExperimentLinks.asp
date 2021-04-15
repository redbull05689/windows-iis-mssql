<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentId = request.querystring("id")
experimentType = request.querystring("type")
revisionId = request.querystring("revisionId")

if canViewExperiment(experimentType,experimentId,session("userId")) then
	call getconnected
	If revisionId = "" then
		set rec = server.createobject("ADODB.RecordSet")
		strQuery = "SELECT * FROM (SELECT * FROM experimentLinksView UNION ALL SELECT * FROM experimentLinks_preSaveView) as T WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
		rec.open strQuery,conn,3,3
		do while not rec.eof
		prefix = GetPrefix(rec("linkExperimentType"))
		experimentPage = GetExperimentPage(prefix)
		experimentPage = mainAppPath & "/" & experimentPage
			%>
				<a href="<%=experimentPage%>?id=<%=rec("linkExperimentId")%>"><%=rec("name")%></a>
				<%If ownsExperiment(experimentType,ExperimentId,session("userId")) then%>
				<a style="margin-left:6px;padding-top:3px;" href="javascript:void(0);" onclick="deleteLink('<%=rec("linkExperimentType")%>','<%=rec("linkExperimentId")%>');return false;"><img border="0" src="<%=mainAppPath%>/images/delete.png" class="png" height="12" width="12"></a>
				<%End if%>
				<p class="linkDescription"><%=rec("details")%></p>
			<%
			rec.movenext
		loop
		rec.close
		set rec = nothing
	End if
	call disconnect
end If
%>