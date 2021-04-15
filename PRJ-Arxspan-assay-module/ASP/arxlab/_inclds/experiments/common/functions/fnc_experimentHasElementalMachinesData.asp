<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function experimentHasElementalMachinesData(experimentType,experimentId,revisionNumber)
	'return true if the specified revision of the experiment has notes
	experimentHasElementalMachinesData = False

	set hnRec = server.createobject("ADODB.RecordSet")
	If revisionNumber = "" then 
		'if the revision number is blank check the current notes table
		strQuery = "SELECT id FROM elementalMachinesData WHERE visible=1 and experimentType="&SQLClean(experimentType,"N","S")&" and experimentId="&SQLClean(experimentId,"N","S")
		hnRec.open strQuery,conn,3,3
		If Not hnRec.eof Then
			experimentHasElementalMachinesData = True
		End if	
	Else
		'if the revision number is not blank then check the specified revision
		strQuery = "SELECT id from elementalMachinesData WHERE visible=1 and experimentType="&SQLClean(experimentType,"N","S")&" and experimentId="&SQLClean(experimentId,"N","S") & " AND revisionNumber<="&SQLClean(revisionNumber,"N","S")
		hnRec.open strQuery,conn,3,3
		If Not hnRec.eof Then
			experimentHasElementalMachinesData = True
		End if
	End if
end function
%>