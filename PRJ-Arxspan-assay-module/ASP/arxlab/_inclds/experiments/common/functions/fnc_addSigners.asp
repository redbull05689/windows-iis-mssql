<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function addSigners(experimentId, experimentType, revisionNumber, author)
    addSigners = ""

    if revisionNumber = "" then
        revisionNumber = getExperimentRevisionNumber(experimentType,experimentId)
    end if

    Set signRec = server.CreateObject("ADODB.RecordSet")
    strQuery = "IF NOT EXISTS (SELECT experimentId, " &_
                                        "experimentType, " &_
                                        "userId, " &_
                                        "revisionNumber " &_
                                "FROM experimentSignatures " &_
                                "WHERE experimentId = " & experimentId & " " &_
                                "AND experimentType = " & experimentType & " " &_
                                "AND userId = " & author & " " &_
                                "AND revisionNumber = " & revisionNumber & ") " &_
                "INSERT INTO experimentSignatures (experimentId, experimentType, userId, revisionNumber, signed) VALUES (" &_
                experimentId & ", " & experimentType & ", " & author & ", " & revisionNumber & ", " & "0)"
    signRec.open strQuery, connAdm, 3, 3
    addSigners = addSigners & "|" & author
    if cstr(author) <> cstr(session("userId")) then
        a = notifySigner(author, experimentId, experimentType)
    end if
    Set signRec = nothing
end function

function notifySigner(author, experimentId, experimentType)
    prefix = getPrefix(experimentType)
    expPage = GetExperimentPage(prefix)

    Set expNameRec = server.CreateObject("ADODB.RecordSet")
    query = "SELECT name FROM allExperiments WHERE experimentType=" & experimentType & " AND legacyId=" & experimentId
    expNameRec.open query, connAdm, 3, 3
    expName = expNameRec("name")
    expNameRec.close
    set expNameRec = Nothing

    note = "User "&session("firstName") & " " & session("lastName") & " requests your signature for experiment <a href=""" & mainAppPath & "/" & expPage & "?id=" & experimentId & """>" & expName & "</a>"
    a = sendNotification(author, "Experiment Sign Request", note, 16)
end function

function checkIfAuthorSaved(author, experimentId, experimentType)
    checkIfAuthorSaved = false
    histTable = "experiments_history"

    if experimentType <> "1" then
        histTable = getPrefix(experimentType) & "Experiments_history"
    end if

    set expCheckRec = server.CreateObject("ADODB.RecordSet")
    strQuery = "SELECT {tablePrefix}.* FROM " & histTable & " h {custFilter} WHERE h.experimentId = " & experimentId & " AND {tablePrefix}.userId = " & author

    tablePrefix = "h"
    custFilter = ""

    if experimentType = "5" then
        tablePrefix = "r"
        custFilter = "LEFT JOIN [ARXSPAN-ORDERS-" & whichServer & "].dbo.requestHistory r ON h.requestRevisionNumber = r.id"
    end if

    strQuery = Replace(strQuery, "{tablePrefix}", tablePrefix)
    strQuery = Replace(strQuery, "{custFilter}", custFilter)
    expCheckRec.open strQuery, connAdm, 3, 3

    if not expCheckRec.eof then
        checkIfAuthorSaved = true
    end if
    set expCheckRec = Nothing
end function

%>