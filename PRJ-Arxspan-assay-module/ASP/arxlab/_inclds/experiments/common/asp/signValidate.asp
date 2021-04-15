<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%

prefix = GetPrefix(experimentType)
experimentTable = GetFullName(prefix, "experiments", true)
selectFields = "userId"

if experimentType = "1" then
	selectFields = selectFields & ", craisStatus"
end if
%>

<%
signError = false
If experimentJSON.get("sign") = "true" Then
	' If the user is signing, first thing we need to do is make sure every required field is filled in
	Set experimentJSONparsed = JSON.parse(request.form("hiddenExperimentJSON"))
	Set requiredFieldsRS = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT experimentConfigJson FROM companies WHERE id="&SQLClean(session("companyId"),"N","S")&" AND experimentConfigJson is not null"
	requiredFieldsRS.open strQuery,connAdm,3,3
	If Not requiredFieldsRS.eof Then
		Set requiredFieldsParsed = JSON.parse(requiredFieldsRS("experimentConfigJson")) 
		errorString = ""

		Dim requiredFieldsFromJson
		Select Case experimentType
			Case "1"
				Set requiredFieldsFromJson = requiredFieldsParsed.expType.chem.requiredFields
			Case "2"
				Set requiredFieldsFromJson = requiredFieldsParsed.expType.bio.requiredFields
			Case "3"
				Set requiredFieldsFromJson = requiredFieldsParsed.expType.free.requiredFields
			Case "4"
				Set requiredFieldsFromJson = requiredFieldsParsed.expType.anal.requiredFields
			Case "5"
				Set requiredFieldsFromJson = requiredFieldsParsed.expType.cust.requiredFields
		End select
		
		dim requiredKeyForProjLinks : for each requiredKeyForProjLinks in requiredFieldsFromJson.enumerate()
			if requiredKeyForProjLinks = "e_projectLinks" then
				%><!-- #include file="requireProjectLink.asp"--><%
			end if
		next

		dim suppliedKey : for each suppliedKey in experimentJSONparsed.enumerate()
			dim requiredKey : for each requiredKey in requiredFieldsFromJson.enumerate()
				if requiredKey = "e_cdxData" AND suppliedKey = "cdxData" then
					If replace(experimentJSON.get("cdxData"),"\\""","\""") = "<?xml version=\""1.0\"" ?><root/>" Then
						errorString = errorString & "cdxData,"
					End If
				elseif suppliedKey = requiredKey AND experimentJSONparsed.get(suppliedKey) = "" then
					errorString = errorString & suppliedKey & ","
				end if
			next
		next

		reactionsSplit = Split(experimentJSON.get("reactants"),",")
		reactionsKeyPrefix = "r1_"
		For i = 0 To UBound(reactionsSplit)
			'reactionsSplit(i) ' Ex. "r3"
			dim requiredKeyForReactions : for each requiredKeyForReactions in requiredFieldsFromJson.enumerate()
				prefixLoc = InStr(requiredKeyForReactions, reactionsKeyPrefix)
				if prefixLoc = 1 then
					requiredKeySplit = Split(requiredKeyForReactions, reactionsKeyPrefix)
					'requiredKeySplit(1) ' Ex. reactantMass
					jsonKey = reactionsSplit(i) & "_" & requiredKeySplit(1)
					if experimentJSON.exists(jsonKey) And (experimentJSON.get(jsonKey) = "") Then
						errorString = errorString & reactionsSplit(i) & "_" & requiredKeySplit(1) & ","
					end if
				end if
			next
		Next

		reagentsSplit = Split(experimentJSON.get("reagents"),",")
		reagentsKeyPrefix = "rg1_"
		For i = 0 To UBound(reagentsSplit)
			'reagentsSplit(i) ' Ex. "rg3"
			dim requiredKeyForReagents : for each requiredKeyForReagents in requiredFieldsFromJson.enumerate()
				prefixLoc = InStr(requiredKeyForReagents, reagentsKeyPrefix)
				if prefixLoc = 1 then
					requiredKeySplit = Split(requiredKeyForReagents, reagentsKeyPrefix)
					'requiredKeySplit(1) ' Ex. reactantMass
					jsonKey = reagentsSplit(i) & "_" & requiredKeySplit(1)
					if experimentJSON.exists(jsonKey) And (experimentJSON.get(jsonKey) = "") then
						errorString = errorString & reagentsSplit(i) & "_" & requiredKeySplit(1) & ","
					end if
				end if
			next
		Next

		productsSplit = Split(experimentJSON.get("products"),",")
		productsKeyPrefix = "p1_"
		For i = 0 To UBound(productsSplit)
			'productsSplit(i) ' Ex. "p3"
			dim requiredKeyForProducts : for each requiredKeyForProducts in requiredFieldsFromJson.enumerate()
				prefixLoc = InStr(requiredKeyForProducts, productsKeyPrefix)
				if prefixLoc = 1 then
					requiredKeySplit = Split(requiredKeyForProducts, productsKeyPrefix)
					'requiredKeySplit(1) ' Ex. reactantMass
					jsonKey = productsSplit(i) & "_" & requiredKeySplit(1)
					if experimentJSON.exists(jsonKey) And (experimentJSON.get(jsonKey) = "") then
						errorString = errorString & productsSplit(i) & "_" & requiredKeySplit(1) & ","
					end if
				end if
			next
		Next

		solventsSplit = Split(experimentJSON.get("solvents"),",")
		solventsKeyPrefix = "s1_"
		For i = 0 To UBound(solventsSplit)
			'solventsSplit(i) ' Ex. "s3"
			dim requiredKeyForSolvents : for each requiredKeyForSolvents in requiredFieldsFromJson.enumerate()
				prefixLoc = InStr(requiredKeyForSolvents, solventsKeyPrefix)
				if prefixLoc = 1 then
					requiredKeySplit = Split(requiredKeyForSolvents, solventsKeyPrefix)
					'requiredKeySplit(1) ' Ex. reactantMass
					jsonKey = solventsSplit(i) & "_" & requiredKeySplit(1)
					if experimentJSON.exists(jsonKey) And (experimentJSON.get(jsonKey) = "") then
						errorString = errorString & solventsSplit(i) & "_" & requiredKeySplit(1) & ","
					end if
				end if
			next
		Next

		If errorString <> "" Then
			response.write(errorString)
			response.End
		End If
	requiredFieldsRS.close
	Set requiredFieldsRS = Nothing
	End If

	If Not experimentJSON.get("verifyState") Then
		response.write("<div id='resultsDiv'>You must check ""Reviewed"" to continue.</div>")
		response.End
		signError = true
	End if		

	If experimentJSON.get("signStatus") = "1" Or experimentJSON.get("signStatus") = "2" Then				
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT " & selectFields & " FROM "&experimentTable&" WHERE id="&SQLClean(experimentJSON.get("experimentId"),"N","S")
		rec.open strQuery,conn,3,3
		If not rec.eof or (experimentType="5" AND checkCoAuthors(experimentId, "5", "signValidate")) Then
			If session("hasCrais") And experimentType="1" Then
				If rec("craisStatus")=3 Or rec("craisStatus")=0 Or IsNull(rec("craisStatus")) Then
					response.write("<div id='resultsDiv'>Experiment cannot be signed without passing regulatory check.</div>")
					response.end
				End if
			End if
			
			passedCredentialCheck = False
			If companyUsesSso() And session("isSsoUser") Then
				passedCredentialCheck = True
			Else
				'pw_stuff
				usersView = getDefaultSingleAppConfigSetting("usersView")
				set passRec = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT id FROM "&usersView&" WHERE email="&SQLClean(experimentJSON.get("signEmail"),"T","S") & " AND password="&SQLClean(experimentJSON.get("password"),"PW","S") & " AND id="&SQLClean(CStr(session("userId")),"N","S")
				'rec.close
				passRec.open strQuery,conn,3,3
				If Not passRec.eof Then
					passedCredentialCheck = True
				End If
				passRec.close
				set passRec = nothing
			End If
			
			If passedCredentialCheck Then
				If experimentJSON.get("signStatus") = "1" then
					newStatusId = "3"
				End If
				If experimentJSON.get("signStatus") = "2" Then
					newStatusId = "5"
				End if
			Else
				If session("companyId") <> "4" then
					response.write("<div id='resultsDiv'>Invalid email or password</div>")
				else
					response.write("<div id='resultsDiv'>Invalid email or employee id</div>")
				End if
				response.end		
				signError = true
			End If
		Else
			response.write("<div id='resultsDiv'>You cannot sign this experiment because you do not own it.</div>")
			response.End
			signError = true
		End If
		Set rec = Nothing
	Else
		response.write("<div id='resultsDiv'>Please select a status</div>")
		response.End
		signError = true
	End If

	If Not signError then
		requesteeId = experimentJSON.get("requesteeId")
		If requesteeId <> "-1" And experimentJSON.get("signStatus") = "2" then
			rwStr = requestWitness(experimentType,experimentId,requesteeId)
			title = "Witness Request"
			prefix = GetPrefix(experimentType)
			expPage = GetExperimentPage(prefix)
			note = "The user "&session("firstName") & " " & session("lastName") & " has requested that you witness <a href="""& expPage &"?id="&experimentId&""">"&experimentJSON.get("e_name")&"</a>"
			
			'Speculative thing to make sure other exp types can send witness requests properly.
			if experimentType <> "5" then
				a = sendNotification(requesteeId,title,note,7)
			end if

			If doNotEndResponse And rwStr <> "" Then
					response.write("<div id='resultsDiv'>"&rwStr&"</div>")
					response.end
			End If
		End If
	End if
End If
%>