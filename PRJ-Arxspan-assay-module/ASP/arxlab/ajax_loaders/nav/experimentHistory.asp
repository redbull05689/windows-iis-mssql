<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%subSectionId= request.querystring("subSectionId")%>
<%If subSectionId="force-change-password" then
	response.end
End if%>
<!-- #include file="../../_inclds/globals.asp"-->
<%
''2232017
Set navRec2 = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT n.history,n.recentHistory FROM navStates n JOIN users u on n.userId=u.id WHERE u.companyId="&SQLClean(session("companyId"),"N","S")&" and n.userId="&SQLClean(session("userId"),"N","S")
navRec2.open strQuery,conn,0,1
If Not navRec2.eof Then
	If navRec2("history") Then
		historyMoreFlag = true
	End If
	If navRec2("recentHistory") Then
		recentHistoryFlag = true
	End If
End If
navRec2.close
Set navRec2 = Nothing
''/2232017
%>
<%subSectionId= request.querystring("subSectionId")
revisionId= request.querystring("revisionId")%>
<%
draftHasUnsavedChanges = request.querystring("draftHasUnsavedChanges")
If LCase(draftHasUnsavedChanges) = "true" Then
	draftHasUnsavedChanges = True
Else
	draftHasUnsavedChanges = False
End if
%>
<%
Select Case subSectionId
Case "experiment"
	historyTableView = "experiments_history"
	expPage = session("expPage")
Case "bio-experiment"
	historyTableView = "bioExperiments_history"
	expPage = "bio-experiment.asp"
Case "free-experiment"
	historyTableView = "freeExperiments_history"
	expPage = "free-experiment.asp"
Case "anal-experiment"
	historyTableView = "analExperiments_history"
	expPage = "anal-experiment.asp"
Case "cust-experiment"
	historyTableView = "custExperiments_history"
	expPage = "cust-experiment.asp"
End select
%>
<%
Set navHistoryRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DISTINCT e.dateSubmitted," &_
	"st.name as status," &_
	"u.firstName as firstName, u.lastName as lastName,{custName}" &_
	"e.statusId," &_
	"e.revisionNumber," &_
	"convert(varchar,e.dateSubmitted,110) as date1," &_
	"convert(varchar,e.dateSubmitted,108) as date2 from "&_ 
	historyTableView&" e INNER JOIN statuses st on st.id = e.statusId {custJoins}" &_
	"LEFT JOIN users u on u.id = e.userId" &_
	" WHERE experimentId="&SQLClean(request.querystring("id"),"N","S")&_
	" ORDER BY revisionNumber DESC"

custName = ""
custJoin = " "

if subSectionId = "cust-experiment" then
	custName = "u2.firstName as requestFirstName, u2.lastName as requestLastName,"
	custJoin = "LEFT JOIN [ARXSPAN-ORDERS-" & whichServer & "].dbo.requestHistory r ON e.requestRevisionNumber=r.id " &_
  				"LEFT JOIN users u2 ON u2.id=r.userId "
end if

strQuery = replace(strQuery, "{custName}", custName)
strQuery = replace(strQuery, "{custJoins}", custJoin)

navHistoryRec.open strQuery,connadm,adOpenForwardOnly,adLockReadOnly
%>
<div id="navRecentHistory" <%If Not recentHistoryFlag then%> style="display:none;"<%else%> style="display:block;height:auto;max-height:300px;overflow-y:auto;"<%End if%> >
<ul style="position:relative;">
<% 
If Not navHistoryRec.eof Then
	If navHistoryRec("statusId") < 5 Or navHistoryRec("statusId") = 7 Or navHistoryRec("statusId") = 8 then%>
		<li id="draftHistoryItem"<%If Not draftHasUnsavedChanges then%> style="display:none;"<%End if%>>
			<a <%If revisionId = "" or revisionId = CStr(navHistoryRec("revisionNumber")) then%>class="navHistorySelected"<%End if%> href="<%=mainAppPath%>/<%=expPage%>?id=<%=request.querystring("id")%>&notebookId=<%=request.querystring("notebookId")%>" style="background-image:url(/arxlab/images/newCreateIcon.gif);">Draft</a>
			<a id="discardDraftLink" class="discardDraftLink" href="javascript:void(0);" style="color:gray;display:block;position:absolute;left:80px;top:0px;width:100px;" onClick="discardChanges();">Discard Draft</a>
		</li>

		<li id="currentHistoryItem"<%If draftHasUnsavedChanges then%> style="display:none;"<%End if%>><a <%If revisionId = "" or revisionId = CStr(navHistoryRec("revisionNumber")) then%>class="navHistorySelected"<%End if%> href="<%=mainAppPath%>/<%=expPage%>?id=<%=request.querystring("id")%>&notebookId=<%=request.querystring("notebookId")%>" style="background-image:url(/arxlab/images/notepad.gif);"><%=currentLabel%></a></li>
<%
	End if
End If

counter = 0
Do While Not navHistoryRec.eof
counter = counter + 1

If counter > 5 Then
	className = "navHistory"
Else
	className = ""
End if

status = navHistoryRec("status")

timeStr = CStr(navHistoryRec("date2"))
timeStr = Left(timeStr,Len(timeStr)-3)
If counter = 1 Then
	%>
		<span style="display:none;" id="lastSaveDate"><script>setElementContentToDateString('lastSaveDate','<%=navHistoryRec("dateSubmitted")%>',<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script></span>
	<%
End if

displayName = navHistoryRec("firstName") & " " & navHistoryRec("lastName")
if subSectionId = "cust-experiment" then
	if not isnull(navHistoryRec("requestFirstName")) then
		displayName = navHistoryRec("requestFirstName") & " " & navHistoryRec("requestLastName")
	end if
end if

%>
<li class="<%=className%>" <%If counter>5 And Not historyMoreFlag then%>style="display:none;"<%End if%> <%If counter>5 And historyMoreFlag then%>style="display:inline;"<%End if%>>
<a title="<%=displayname%>" <%If revisionId = CStr(navHistoryRec("revisionNumber")) then%>class="navHistorySelected"<%End if%> href="<%=mainAppPath%>/<%=expPage%>?id=<%=request.querystring("id")%>&revisionId=<%=navHistoryRec("revisionNumber")%>" <% 

	Select Case status
		Case "regulatory check"
			response.write("style=""background-image:url(/arxlab/images/goldstar.png);""") 
		Case "created"
			response.write("style=""background-image:url(/arxlab/images/newCreateIcon.gif);""") 
		Case "saved"
			response.write("style=""background-image:url(/arxlab/images/newSavedIcon.gif);""")
		Case "reopened"
			response.write("style=""background-image:url(/arxlab/images/newReopenedIcon.gif);""") 
		Case "signed - open"
			response.write("style=""background-image:url(/arxlab/images/newSignedIcon.gif);""") 
		Case "signed - closed"
			response.write("style=""background-image:url(/arxlab/images/newSignedIcon.gif);""") 
		Case "witnessed"
			response.write("style=""background-image:url(/arxlab/images/newWitnessedIcon.gif);""") 
		Case "rejected"
			response.write("style=""background-image:url(/arxlab/images/newRejectedIcon.gif);""") 
		Case "Pending Not Pursued"
			response.write("style=""background-image:url(/arxlab/images/newPendingAbandonmentIcon.gif);""")
		Case "Not Pursued"
			response.write("style=""background-image:url(/arxlab/images/newAbandonedIcon.gif);""")
	End select

%>><span id="hd_<%=navHistoryRec("revisionNumber")%>_<%=request.querystring("id")%>"><script>setElementContentToDateString('hd_<%=navHistoryRec("revisionNumber")%>_<%=request.querystring("id")%>','<%=navHistoryRec("dateSubmitted")%>',<%If session("useGMT") Then%>true<%else%>false<%end if %>);</script></span></a></li>
<%
	navHistoryRec.moveNext
	Loop
%>

<%
If counter > 5 Then
	%>
	<div class="navSectionFooter navFooter"><a style="font-weight: bold;" id="navHistoryLink" href="javascript:void(0);" onclick="navViewMore('navHistory');return false;"><%If Not historyMoreFlag then%><%=UCase(viewMoreLabel)%> >><%else%><< VIEW LESS <%End if%></a></div>
	<%
End if
%>
</ul>
</div>
