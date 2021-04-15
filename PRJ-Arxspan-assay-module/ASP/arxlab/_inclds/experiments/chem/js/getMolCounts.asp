<%
' //Example Code
' $.get( "mainAppPath/_inclds/experiments/chem/js/getMolCounts.asp", { experimentId: experimentId, experimentType: 1, revisionId: revisionId, random: $.now() } )
'   .done(function( data ) {
'     alert( "Data Loaded: " + data );
' 	numReactants = data.numReactants;
' 	numReagents = data.numReagents;
' 	numProducts = data.numProducts;
' 	numSolvents = data.numSolvents;
'   });
%>

<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_canViewExperiment.asp"-->
<!-- #include virtual="/arxlab/_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->

<%
numReactants = 0
numReagents = 0
numProducts = 0
numSolvents = 0

experimentId = Clng(request.querystring("experimentId"))

if request.querystring("revisionId") <> "" then
    revisionId = CLng(request.querystring("revisionId"))
else
    revionsId = ""
end if


ownsExp = ownsExperiment(1,experimentId,session("userId"))

if canViewExperiment("1",experimentId,session("userId"))  then

    if revisionId = "" then

        set nrRec = server.createobject("ADODB.RecordSet")
        strQuery = "SELECT id FROM reactants WHERE experimentId="&SQLClean(experimentId,"N","S")
        if not ownsExp then
            strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
        end if
        nrRec.open strQuery,conn,3,3
        numReactants = nrRec.RecordCount
        nrRec.close

        strQuery = "SELECT id FROM reagents WHERE experimentId="&SQLClean(experimentId,"N","S")
        if not ownsExp then
            strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
        end if
        nrRec.open strQuery,conn,3,3
        numReagents = nrRec.RecordCount
        nrRec.close

        strQuery = "SELECT id FROM products WHERE experimentId="&SQLClean(experimentId,"N","S")
        if not ownsExp then
            strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
        end if
        nrRec.open strQuery,conn,3,3
        numProducts = nrRec.RecordCount
        nrRec.close

        strQuery = "SELECT id FROM solvents WHERE experimentId="&SQLClean(experimentId,"N","S")
        if not ownsExp then
            strQuery = strQuery & " and (isDraft<>1 or isDraft is null)"
        end if
        nrRec.open strQuery,conn,3,3
        numSolvents = nrRec.RecordCount
        nrRec.close

        set nrRec = nothing
        
    else

        set nrRec = server.createobject("ADODB.RecordSet")
        strQuery = "SELECT id FROM reactants_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
        nrRec.open strQuery,conn,3,3
        numReactants = nrRec.RecordCount
        nrRec.close

        strQuery = "SELECT id FROM reagents_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
        nrRec.open strQuery,conn,3,3
        numReagents = nrRec.RecordCount
        nrRec.close

        strQuery = "SELECT id FROM products_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
        nrRec.open strQuery,conn,3,3
        numProducts = nrRec.RecordCount
        nrRec.close

        strQuery = "SELECT id FROM solvents_history WHERE experimentId="&SQLClean(experimentId,"N","S") & " and revisionId=" & SQLClean(revisionId,"N","S")
        nrRec.open strQuery,conn,3,3
        numSolvents = nrRec.RecordCount
        nrRec.close

        set nrRec = nothing
        
    end if
end if
response.ContentType = "application/json"
response.write "{""numReactants"": """ & numReactants & """, ""numReagents"": """ & numReagents & """, ""numProducts"": """& numProducts & """, ""numSolvents"": """ & numSolvents & """}"
%>