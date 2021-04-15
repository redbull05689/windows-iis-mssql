<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")

Call getconnectedadm

If ownsExperiment(experimentType,experimentId,session("userId")) then
	prefix = GetPrefix(experimentType)
	attachmentsPreSaveTable = GetFullName(prefix, "attachments_preSave", true)
	notesPreSaveTable = GetFullName(prefix, "notes_preSave", true)
	'delete items from all presave tables
	strQuery = "DELETE FROM experimentLinks_preSave WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE FROM experimentRegLinks_preSave WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE FROM "&attachmentsPreSaveTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdm.execute(strQuery)
	strQuery = "DELETE FROM "&notesPreSaveTable&" WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdm.execute(strQuery)
	'delete JSON draft object from experimentDrafts
	strQuery = "DELETE FROM experimentDrafts WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND experimentType="&SQLClean(experimentType,"N","S")
	connAdm.execute(strQuery)
	If experimentType="1" Then
		'delete all draft molecules for chemistry experiments
		strQuery = "DELETE FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND isDraft=1"
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND isDraft=1"
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND isDraft=1"
		connAdm.execute(strQuery)
		strQuery = "DELETE FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND isDraft=1"
		connAdm.execute(strQuery)
	End if
End If

Call disconnectadm()
%>