<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->
<%
'the purpose of this script is to determine whether or not a chemistry process is still being processed by Python
experimentId = request.querystring("id")
call getconnected
Call getconnectedAdm
'clear the experimentLoading flag if more than 2 minutes has passed
strQuery = "UPDATE experimentLoading SET cleared=1 WHERE experimentId="&SQLClean(experimentId,"N","S")&" AND datediff(mi,dateSubmitted,GETDATE())>=2"
connAdm.execute(strQuery)
Call disconnectAdm
set rec = server.createobject("ADODB.RecordSet")
strQuery = "SELECT COUNT(*) as numLoading FROM experimentLoading WITH(NOWAIT) WHERE experimentId=" & SQLClean(experimentId,"N","S")&" AND cleared=0"
rec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
if rec("numLoading") <> 0 Then
	'if experiment is loading
	response.write("yes")
Else
	'experiment is done loading.  return the numbers of each type of molecules to load
	set nrRec = server.createobject("ADODB.RecordSet")
	strQuery = "SELECT COUNT(*) as numReactants FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
	nrRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	numReactants = nrRec("numReactants")
	nrRec.close
	strQuery = "SELECT COUNT(*) as numReagents FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
	nrRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	numReagents = nrRec("numReagents")
	nrRec.close
	strQuery = "SELECT COUNT(*) as numSolvents FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
	nrRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	numSolvents = nrRec("numSolvents")
	nrRec.close
	strQuery = "SELECT COUNT(*) as numProducts FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
	nrRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	numProducts = nrRec("numProducts")
	nrRec.close
	strQuery = "SELECT currLetter FROM experiments WHERE id="&SQLClean(experimentId,"N","S")
	nrRec.open strQuery,conn,adOpenForwardOnly,adLockReadOnly
	currLetter = nrRec("currLetter")
	nrRec.close
	set nrRec = Nothing
	
	Set d = JSON.parse("{}")
	d.Set "numReactants", numReactants
	d.Set "numReagents", numReagents
	d.Set "numSolvents", numSolvents
	d.Set "numProducts", numProducts
	d.Set "currLetter", currLetter
	data = JSON.stringify(d)
	Response.Status = "200"
	response.write(data)
end if
rec.close
set rec = Nothing
Call disconnect
%>