<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%

' Function to log the given search in the savedUserSearchQueries table.
' searchTypeCode - The type code that identifies what kind of search this was.
' searchJSONStr - The JSON string of the search query.
' structureJSONStr - The JSON string of the structure search.
function logSearch(searchTypeCode, searchJSONStr, structureJSONStr)

    searchJSONStr = normalizeJSONStr(searchJSONStr)
    structureJSONStr = normalizeJSONStr(structureJSONStr)

    Call getconnectedadm
    Set logRec = server.CreateObject("ADODB.RecordSet")
    logQuery = "INSERT INTO savedUserSearchQueries " &_
        "(userId, companyId, searchDate, searchTypeCode, searchJSON, structureJSON) " &_
        "VALUES " &_
        "(" & SQLClean(session("userId"), "N", "S") & ", " &_
        SQLClean(session("companyId"), "N", "S") & ", " &_
        "GETUTCDATE(), " &_
        SQLClean(searchTypeCode, "N", "S") & ", " &_
        SQLClean(searchJSONStr, "T", "S") & ", " &_
        SQLClean(structureJSONStr, "T", "S") &_
        ");"

    connAdm.execute(logQuery)
end function

' Helper function to null JSONStr if its an empty string.
' JSONStr - The string to sniff out.
function normalizeJSONStr(JSONStr)
    if JSONStr = "" or JSONStr = "{}" or JSONStr = "[]" then
        JSONStr = null
    end if

    normalizeJSONStr = JSONStr
end function
%>