<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function addSignature(experimentId,experimentType,revisionNumber,userId)
    addSignature = ""
    strQuery =  "UPDATE experimentSignatures " &_
                "SET signed=1, " &_
                "dateSigned = getutcdate()," & " " &_
                "dateSignedServer = getdate()" & " " &_
                "WHERE experimentId=" & experimentId & " " &_
                "AND experimentType = " & experimentType & " " &_
                "AND userId = " & userId & " " &_
                "AND revisionNumber = " & revisionNumber &_
                "AND signed = 0 " 
    
    Set rec = server.CreateObject("ADODB.RecordSet")
    rec.open strQuery, connAdm, 3, 3
    Set rec = Nothing

    updateQuery = "UPDATE custExperiments_history " &_
    "SET dateSubmitted=e.dateSigned, " &_ 
    "dateSubmittedServer=e.dateSignedServer " &_
    "FROM experimentSignatures e " &_
    "WHERE custExperiments_history.experimentId= " & experimentId & " " &_
    "AND custExperiments_history.revisionNumber= " & revisionNumber & " " &_
    "AND e.experimentId=" & experimentId & " " &_
    "AND e.experimentType= " & experimentType & " " &_
    "AND e.userId= " & userId & " " &_
    "AND e.revisionNumber= " & revisionNumber
    Set updateRec = server.CreateObject("ADODB.RecordSet")
    updateRec.open updateQuery, connAdm, 3, 3
    Set updateRec = Nothing
    
    ' Check to see if it is SAFE/soft Signed, if so, don't make a new PDF
    strQuery2 = "SELECT softSigned " &_
            "FROM custExperiments " &_
            "WHERE id=" & experimentId
                
    Set softSignedRec = server.CreateObject("ADODB.RecordSet")
    softSignedRec.open strQuery2, connAdm, 3, 3
	makePDF = True
    if not softSignedRec.eof then
        if softSignedRec("softSigned") = 1 then
            makePDF = False
        end if
    end if
	if makePDF = True then
		a = savePDF(experimentType,experimentId,revisionNumber,true,true,false)
	end if
    
	check = checkIfAllSigned(experimentId, experimentType, revisionNumber)
    if check then
    

        requesteeId = getWitnessId(experimentId, experimentType)
        signStatus = getSignStatus(experimentId, experimentType)
		If requesteeId <> "-1" And signStatus = "5" then
			'rwStr = requestWitness(experimentType,experimentId,requesteeId)
			'session("TEST") = rwStr
            title = "Witness Request"
			prefix = GetPrefix(experimentType)
			expPage = GetExperimentPage(prefix)
            expName = GetExpName(experimentId, experimentType)
			note = "The user "&session("firstName") & " " & session("lastName") & " has requested that you witness <a href="""& expPage &"?id="&experimentId&""">"&expName&"</a>"
			
			a = sendNotification(requesteeId,title,note,7)

			'If doNotEndResponse And rwStr <> "" Then
			'		response.write("<div id='resultsDiv'>"&rwStr&"</div>")
			'		response.end
			'End If
		End If

        addSignature = "Reload"
    end if
end function

function checkIfAllSigned(experimentId, experimentType, revisionNumber)
    checkIfAllSigned = false
    ' need to make sure userId > 0, because the current app service will return userId 0 as a collaborator if there it is set to null.....sad.
    strQuery = "SELECT COUNT(*) AS count " &_
                "FROM experimentSignatures " &_
                "WHERE experimentId=" & experimentId & " " &_
                "AND experimentType = " & experimentType & " " &_
                "AND revisionNumber = " & revisionNumber & " " &_
                "AND userId > 0 " &_
                "AND signed=0"
                
    Set checkRec = server.CreateObject("ADODB.RecordSet")
    checkRec.open strQuery, connAdm, 3, 3

    if not checkRec.eof then
        if checkRec("count") = 0 then
            checkIfAllSigned = true
        end if
    else
        checkIfAllSigned = true    
    end if

    checkRec.close
    Set checkRec = Nothing
end function

function getWitnessId(experimentId, experimentType)
    getWitnessId = "-1"
    strQuery = "SELECT requesteeId FROM witnessRequests WHERE experimentTypeId=" & experimentType & " AND experimentId=" & experimentId
    Set witnessRec = server.CreateObject("ADODB.RecordSet")
    
    witnessRec.open strQuery, connAdm, 3, 3
    if not witnessRec.eof then
        getWitnessId = witnessRec("requesteeId")
    end if
    witnessRec.close
    
    set witnessRec = Nothing
end function

function getSignStatus(experimentId, experimentType)
    getSignStatus = ""

    prefix = getPrefix(experimentType)
    table = IIF(prefix = "", "experiments", prefix & "Experiments")

    strQuery = "SELECT statusId FROM " & table & " WHERE id=" & experimentId
    Set signRec = server.CreateObject("ADODB.RecordSet")
    
    signRec.open strQuery, connAdm, 3, 3
    if not signRec.eof then
        getSignStatus = signRec("statusId")
    end if
    signRec.close
    
    set signRec = Nothing
end function

function getExpName(experimentId, experimentType)
    getExpName = ""
    strQuery = "SELECT name FROM allExperiments WHERE legacyId=" & experimentId & " AND experimentType=" & experimentType

    Set expRec = server.CreateObject("ADODB.RecordSet")
    expRec.open strQuery, connAdm, 3, 3
    if not expRec.eof then
        getExpName = expRec("name")
    end if
    expRec.close
    set expRec = nothing

end function
%>