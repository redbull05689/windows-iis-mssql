<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%

    function getAllExperimentsId(experimentId, experimentType)
        getAllExperimentsId = 0

        allExpQuery = "SELECT id FROM allExperiments " &_
                        "WHERE legacyId={expId}" &_
                        " AND experimentType={expType}" &_
                        " AND companyId={companyId}"
        allExpQuery = Replace(allExpQuery, "{expId}", SQLClean(experimentId, "N", "S"))
        allExpQuery = Replace(allExpQuery, "{expType}", SQLClean(experimentType, "N", "S"))
        allExpQuery = Replace(allExpQuery, "{companyId}", SQLClean(session("companyId"), "N", "S"))

        set allExpIdRec = Server.CreateObject("ADODB.RecordSet")
        allExpIdRec.open allExpQuery, conn, 3, 3
        if not allExpIdRec.eof then
            getAllExperimentsId = allExpIdRec("id")
        end if
        
        allExpIdRec.close
    end function

%>