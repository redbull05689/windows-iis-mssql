<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Set searchParamJson = JSON.parse("{}")
searchParamJson.Set "searchType", "FULL_STRUCTURE"

Set tRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT optionFlag FROM options WHERE optionName='tautomers'"
tRec.open strQuery,jchemRegConn,3,3
If tRec("optionFlag") = 1 Then
	searchParamJson.Set "tautomers", "ON"
End If
tRec.close

strQuery = "SELECT optionFlag FROM options WHERE optionName='absoluteStereo'"
tRec.open strQuery,jchemRegConn,3,3
If tRec("optionFlag") <> 1 Then
	'absoluteStereo is now the default so we only set it when it's turned OFF
	searchParamJson.Set "absoluteStereo", "CHIRAL_FLAG"
End If
tRec.close
Set tRec = Nothing
%>