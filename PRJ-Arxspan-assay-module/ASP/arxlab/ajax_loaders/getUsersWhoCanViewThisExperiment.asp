<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
experimentId = request.querystring("experimentId")
experimentType = request.querystring("experimentType")

usersWhoCanViewThisExperiment = usersWhoCanViewExperiment(experimentType,experimentId)
usersTable = getDefaultSingleAppConfigSetting("usersTable")
'NOTE: this function gets users who can view the experiment except the current logged in user 
'this is what we are useing for collaborator lists 
call getconnectedadm
Set uRec = Server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT id, firstName, lastName,email FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id <>" & SQLClean(session("userId"),"N","S")& " AND id in("&usersWhoCanViewThisExperiment&") and enabled=1"
	strQuery = Replace(strQuery, ",,", ",") 'Weird fix for Tim Rindfleisch where there was a double comma in one of the user ID strings.
	strQuery = strQuery & " ORDER by firstName"
	uRec.open strQuery,conn,3,3
   Dim namesStr 
        namesStr= "[ "
		Do While Not uRec.eof
            namesStr = namesStr & "{ ""name"":" &"""" &uRec("firstName") & " " &  uRec("lastName") &""""
			namesStr = namesStr & ", ""email"" :" & """"&uRec("email") & """" 
			namesStr = namesStr & ", ""id"" : " & uRec("id") & "},"		
			uRec.movenext
	loop
namesStr = Left(namesStr,Len(namesStr)-1)
namesStr = namesStr & "]"
response.contentType = "application/json charset=utf-8"
response.write(namesStr)
uRec.close
Set uRec = nothing
%>	