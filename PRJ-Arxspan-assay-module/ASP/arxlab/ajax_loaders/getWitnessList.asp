<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
call getconnected

gwl_logEventsToFile = False
If 1=2 And (session("email") = "julien@broadinstitute.org" Or session("email") = "support@arxspan.com") Then
	gwl_logEventsToFile = True
End If
If gwl_logEventsToFile Then
	gwl_logpath = "C:/Temp/getWitnessList-log.txt"
	set gwl_logfs=Server.CreateObject("Scripting.FileSystemObject")
	set gwl_logfile = Nothing

	With (gwl_logfs)
	  If .FileExists(gwl_logpath) Then
		Set gwl_logfile = gwl_logfs.OpenTextFile(gwl_logpath, 8)
	  Else 
		Set gwl_logfile = gwl_logfs.CreateTextFile(gwl_logpath)
	  End If 
	End With

	gwl_logfile.WriteLine(Now & ": enter getWitnessList.asp")
End If
%>
<label for="requesteeIdBox" class="select-style-label">Witness</label>
<div class="select-style">
	<select name="requesteeIdBox" id="requesteeIdBox">
	<option value="-2" <%If "-2" = session("defaultWitnessId") then%> SELECTED<%End if%>>--Please select a Witness--</option>
	<%
	requireWitness = checkBoolSettingForCompany("requireWitness", session("companyId"))
	if not requireWitness then
	%>
		<%If whichClient = "TAKEDA_VBU" Then%>
		<option value="-1" <%If "-1" = session("defaultWitnessId") then%> SELECTED<%End if%>>--Not Pursued--</option>
		<%Else%>
		<option value="-1" <%If "-1" = session("defaultWitnessId") then%> SELECTED<%End if%>>--No Witness--</option>
		<%End If%>
	<%end if
	
	experimentId = request.querystring("experimentId")
	experimentType = request.querystring("experimentType")

	usersTable = getDefaultSingleAppConfigSetting("usersTable")
	Set uRec = Server.CreateObject("ADODB.RecordSet")

	noCoAuthQuery = "SELECT id, firstName, lastName FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id <>" & SQLClean(session("userId"),"N","S")& " AND id in("&getUsersICanSee()&") and enabled=1"

	if request.querystring("experimentType") = "5" then
		
		coAuths = getCoAuthors(experimentId, experimentType, getExperimentRevisionNumber(experimentType, experimentId))	
		collaborated = getUsersWhoCollaborated(experimentId, experimentType)
		' 6771: A user can be a co-author and still witness as long as they "Made no material changes ie they did not add anything and save into the history of the experiment" - Amanda
		' coAuths = coAuths & "," & collaborated
		collaborated_temp = "," & collaborated & ","
		coAuthsToExclude = ""
		listOfCoAuths= Split(coAuths,",")
		If ubound(listOfCoAuths) >= 0 then
			For i = 0 To ubound(listOfCoAuths) ' Loop through the list of coAuths
				If IsInteger(listOfCoAuths(i)) and listOfCoAuths(i) <> "" then	   
					auth = "," & listOfCoAuths(i) & ","
					If listOfCoAuths(i) <> session("userId") And InStr(collaborated_temp, auth) > 0 Then ' Exclude this co-author from the witness list since he/she has made changes
						coAuthsToExclude = coAuthsToExclude & listOfCoAuths(i) & ","
					End if
				End if
			next
			If right(coAuthsToExclude, 1) = "," Then
				coAuthsToExclude = Left(coAuthsToExclude, Len(coAuthsToExclude) - 1)
			End if
		End If 

		If coAuthsToExclude <> "" Then
			coAuthsToExclude = coAuthsToExclude & "," & collaborated
		End If

		Do While right(coAuthsToExclude, 1) = ","
			coAuthsToExclude = Left(coAuthsToExclude, Len(coAuthsToExclude) - 1)
		Loop
		if coAuthsToExclude = "" then
			strQuery = noCoAuthQuery
		else 
			strQuery = "SELECT id, firstName, lastName FROM "&usersTable&" where companyId="&SQLClean(session("companyId"),"N","S") & " AND id <>" & SQLClean(session("userId"),"N","S")& " AND id NOT IN (" & coAuthsToExclude & ") AND id in("&getUsersICanSee()&") and enabled=1"
		end if 
	else
		strQuery = noCoAuthQuery
	end if
	''412015
	If session("useSafe") Then
		strQuery = strQuery &" AND softToken=1"
	End If
		
	' execute the stored procedure to get the full user id list of folk that can view the experiment	
	Set usersStoredProc = server.CreateObject("ADODB.RecordSet")	
	usersThatCanViewExperimentQuery = "EXEC dbo.elnGetUsersThatCanViewExperiment" &_
	    " @experimentId=" & SQLClean(experimentId,"N","S") &_
	    ", @experimentType=" & SQLClean(experimentType,"N","S")
			
	usersStoredProc.open usersThatCanViewExperimentQuery,connNoTimeout,0,-1		
	
	userString = ""
	Do While Not usersStoredProc.eof
		userString = userString & usersStoredProc("id") & ","
		usersStoredProc.movenext
	loop

	usersStoredProc.close
	set usersStoredProc = nothing

	' limit the query to only show users that can view the experiment
	If Len(userString) > 0 Then
		userString = Mid(userString,1,Len(userString)-1) ' remove the trailing comma from the list
		strQuery = strQuery & " AND id IN (" & userString & ")"
	End If

	strQuery = strQuery & " ORDER by firstName"
	
	''/412015
	uRec.open strQuery,conn,3,3
	Do While Not uRec.eof
		If gwl_logEventsToFile Then
			gwl_logfile.WriteLine(Now & ": adding user " & uRec("firstName") & " " & uRec("lastName"))
		End If
		%>
		<option value="<%=uRec("id")%>" <%If uRec("id") = session("defaultWitnessId") then%> SELECTED<%End if%>><%=uRec("firstName")%>&nbsp;<%=uRec("lastName")%></option>
		<%		
		uRec.movenext
	loop
	If gwl_logEventsToFile Then
		gwl_logfile.WriteLine(Now & ": exit getWitnessList.asp")
		gwl_logfile.close
		set gwl_logfile=nothing
		set gwl_logfs=nothing
	End If
	%>
	</select>
</div>