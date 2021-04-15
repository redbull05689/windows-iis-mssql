<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function getCompanyIdByUser(userId)
	If IsNull(userId) Or userId=0 Or userId = "" Or userId = session("userId") Then
		getCompanyIdByUser = session("companyId")
	Else
		'get the company of the supplied user
		'used to generate the correct paths to files so that users can view files that are owned by others
		usersTable = getDefaultSingleAppConfigSetting("usersTable")
		set muRec = server.createobject("ADODB.RecordSet")
		strQuery = "SELECT companyId FROM "&usersTable&" WHERE id="&SQLClean(userId,"N","S")
		muRec.open strQuery,conn,3,3
		if not muRec.eof then'
			'if we find the user then set the functions return value to the company Id
			getCompanyIdByUser = muRec("companyId")
		Else
			'nxq ?
			getCompanyIdByUser = "0"
			'getCompanyIdByUser = muRec("companyId")
		end if
	End If
end Function
%>