<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%


'Returns an empty string if there is nothing checked out, otherwise, a comma seperated list of file names (or "Chemistry Reaction").
function getListOfCheckedOutFiles(experimentType,experimentId)
	
	attachmentTable = "attachments"
	prefix = GetPrefix(experimentType)
	attachmentTable = GetFullname(prefix, attachmentTable, true)
	attachmentPresaveTable = "attachments_preSave"
	attachmentPresaveTable = GetFullName(prefix, attachmentPresaveTable, true)
	strQuery = "SELECT id, name FROM " & attachmentTable & " WHERE experimentId="&SQLClean(experimentId,"N","S") & " AND checkedOut = 1"
	Set caRec = server.CreateObject("ADODB.RecordSet")
	caRec.open strQuery,conn,3,3
	'loop through all attachments

	listOfFiles = ""
	Do While Not caRec.eof
		if listOfFiles <> "" then
			listOfFiles = listOfFiles + ", "
		end if
		listOfFiles = listOfFiles + cStr(caRec("name"))
		caRec.movenext
	loop
	caRec.close
	Set caRec = Nothing

	' check the chem
	if experimentType = 1 then
		chemStrQuery = "select id from experiments where id = " & SQLClean(experimentId,"N","S") & " AND checkedOut is not null"
		Set chemRec = server.CreateObject("ADODB.RecordSet")
		chemRec.open chemStrQuery,conn,3,3

		Do While Not chemRec.eof
			if listOfFiles <> "" then
				listOfFiles = listOfFiles + ", "
			end if
			listOfFiles = listOfFiles + "Chemistry Reaction"
			chemRec.movenext
		loop
	end if

	getListOfCheckedOutFiles = listOfFiles
end function
%>