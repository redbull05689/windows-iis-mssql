<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
regEnabled = true
%>
<%
subSectionId = changeStatePage 
%>
<!-- #include virtual="/arxlab/_inclds/globals.asp"-->
<%
'this script is for setting flags for which nav items are open/closed

'On Error Resume Next
Call getConnectedAdm
state = request.querystring("state")
id = request.querystring("stateId")

'select the appropriate column and set its state to the specified state
Select Case id
	Case "navNotebooks"
		connAdm.execute("UPDATE navStates SET myNotebooks="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navProjects"
		connAdm.execute("UPDATE navStates SET myProjects="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navSharedNotebooks"
		connAdm.execute("UPDATE navStates SET sharedNotebooks="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navSharedProjects"
		connAdm.execute("UPDATE navStates SET sharedProjects="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navGroupInvites"
		connAdm.execute("UPDATE navStates SET groupInvites="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navHistory"
		connAdm.execute("UPDATE navStates SET history="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navRecentHistory"
		connAdm.execute("UPDATE navStates SET recentHistory="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navNotebookInvites"
		connAdm.execute("UPDATE navStates SET notebookInvites="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navProjectInvites"
		connAdm.execute("UPDATE navStates SET projectInvites="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navGroupInvites"
		connAdm.execute("UPDATE navStates SET groupInvites="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navWitnessRequests"
		connAdm.execute("UPDATE navStates SET witnessRequests="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navRecentExperiments"
		connAdm.execute("UPDATE navStates SET recentExperiments="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navTools"
		connAdm.execute("UPDATE navStates SET tools="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navTemplates"
		connAdm.execute("UPDATE navStates SET templates="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navRegistration"
		connAdm.execute("UPDATE navStates SET registration="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navOrders"
		connAdm.execute("UPDATE navStates SET orders="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navMyExperimentsMore"
		connAdm.execute("UPDATE navStates SET myExperimentsMore="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "navSharedExperimentsMore"
		connAdm.execute("UPDATE navStates SET sharedExperimentsMore="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
	Case "tree"
		connAdm.execute("UPDATE navStates SET tree="&SQLClean(state,"N","S")& " WHERE userId="&SQLClean(session("userId"),"N","S"))
End Select
disconnectAdm
%>