<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp" -->

<%
	' 7632 - fetchExperimentSearchTypeAhead.asp was not fit for task for this ticket, so this script aims to fetch a list of experiments
	' that the current user can write to. This is set up as a POST for parity with the aforementioned script, but the input is optional
	' to facilitate the use of this independently of the original use case. This is set up directly in the ASP as opposed to a stored procedure
	' because one of the requirements was to return experiments where the current user is a coauthor, meaning there is a mandatory call to the
	' appSvc to fetch the required data, and I don't think there's a clean way to use the returned data in a stored procedure.
	query = Request.form("userInputValue")
	nameFilter = ""

	' If we have a search query, then add a filter clause to the query to check for the query as a substring of experiment names.
	if query <> "" then
		nameFilter =	"AND (CHARINDEX(? COLLATE Latin1_General_CI_AS, e.name COLLATE Latin1_General_CI_AS) > 0 " &_
						"		OR CHARINDEX(? COLLATE Latin1_General_CI_AS, e.userExperimentName COLLATE Latin1_General_CI_AS) > 0) "
	end if

	' Start by determining which requests the current user is a collaborator on. We can do this
	' by hitting an endpoint in the appSvc.
	collaboratorRequestClause = ""
	collaboratorRequestIdJSONStr = getRequestListFromCollaborators(session("userId"))
	set collaboratorRequestIdJSON = JSON.parse(collaboratorRequestIdJSONStr)

	' Make sure the response was successful. If it was not successful, return an empty array string and terminate.
	if collaboratorRequestIdJSON.get("result") <> "success" then
		response.write "[]"
		response.end
	end if

	' Pull the data JSON string out of the response JSON and replace the brackets with parenthesis.
	collaboratorRequestIdListStr = collaboratorRequestIdJSON.get("data")
	collaboratorRequestIdListStr = Replace(collaboratorRequestIdListStr, "[", "(")
	collaboratorRequestIdListStr = Replace(collaboratorRequestIdListStr, "]", ")")

	' If we don't have an empty set of parenthesis, then there are requests where the current user is a valid collaborator,
	' so make the collaborator request clause check for the cust exp IDs that correspond to the request IDs.
	if collaboratorRequestIdListStr <> "()" then
		collaboratorRequestClause = " OR (e.legacyId IN " &_
			"(SELECT id FROM custExperiments WHERE requestId IN " & collaboratorRequestIdListStr & ") " &_
			"AND e.experimentType=5) "
	end if

	' Now the actual query: we want a few IDs from the allExperiments table, a few names, the experiment type and the owner's ID, all
	' from the current company where the experiment is still open, the owner ID either matches the current user or the current user is
	' a collaborator and either of the experiment names has a match with the passed in query.
	strQuery = "SELECT TOP 10000 " &_
					"e.id, " &_
					"e.legacyId, " &_
					"e.name, " &_
					"e.userExperimentName, " &_
					"e.experimentType, " &_
					"e.userId " &_
				"FROM allExperiments e " &_
				"WHERE e.companyId=? " &_
				"AND e.statusId NOT IN (5,6) " &_
				"AND (e.userId=? " & collaboratorRequestClause & " ) " &_
				"AND e.visible=1 " &_
				nameFilter & " " &_
				"FOR JSON AUTO;"

	Set cmd = server.createobject("ADODB.Command")
	cmd.ActiveConnection = connAdm
	cmd.CommandText = strQuery
	cmd.CommandType = adCmdText

	cmd.Parameters.Append(cmd.CreateParameter("@companyId", adInteger, adParamInput, len(session("companyId")), session("companyId")))
	cmd.Parameters.Append(cmd.CreateParameter("@userId", adInteger, adParamInput, len(session("userId")), session("userId")))

	' Only add these parameters if we have a search query.
	if query <> "" then
		cmd.Parameters.Append(cmd.CreateParameter("@name", adVarChar, adParamInput, len(query), query))
		cmd.Parameters.Append(cmd.CreateParameter("@userExpName", adVarChar, adParamInput, len(query), query))
	end if

	set rs = cmd.execute

	' If there are no results, then write an empty array.
	if rs.eof then
		response.write "[]"
	end if

	' Otherwise, write out the results we get. I would normally have a return variable and response.write that at the end of the script
	' and assign the value of the results to said variable if the results exist, but FOR JSON AUTO doesn't seem to like that style of programming.
	Do While Not rs.eof
		response.write rs.Fields.Item(0)
		rs.movenext
	Loop
	rs.close
	set rs = nothing

    response.end
%>

