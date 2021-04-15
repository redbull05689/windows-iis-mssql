<%@Language="VBScript"%>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'save chemistry experiment%>
<%Server.scriptTimeout = 6000%>
<%
Response.CodePage = 65001
%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/database/functions/fnc_callStoredProcedure.asp"-->
<!-- #include virtual="/arxlab/apis/eln/fnc_getElnApiServerName.asp"-->

<%
experimentJSON = request.form("experimentJSON")
Set experimentJSON = JSON.parse(experimentJSON)
experimentType = request.form("experimentType")
experimentId = request.form("experimentId")
revisionNumber = request.form("revisionNumber")
molType = request.form("molType")
thePrefix = request.form("prefix")


if canViewExperiment(experimentType,experimentId,session("userId"))  then

    ' we only care about the new items, store the real JSON value somewhere, and set it to just the new stuff
	oldReactants = experimentJSON.get("reactants")
	oldReagents = experimentJSON.get("reagents")
	oldProducts = experimentJSON.get("products")
	oldSolvents = experimentJSON.get("solvents")
	experimentJSON.Set "reactants", ""
	experimentJSON.Set "reagents", ""
	experimentJSON.Set "products", ""
	experimentJSON.Set "solvents", ""

	If molType = "reactant" then
		experimentJSON.Set "reactants", thePrefix
	elseif molType = "reagent" then
		experimentJSON.Set "reagents", thePrefix
	elseif molType = "products" then
		experimentJSON.Set "products", thePrefix
	elseif molType= "solvent" then
		experimentJSON.Set "solvents", thePrefix
	End if

    Call getconnectedadmTrans
    'start transaction
    connAdmTrans.beginTrans
    %>
    <!-- #include file="../_inclds/experiments/chem/asp/saveReactants.asp"-->
    <!-- #include file="../_inclds/experiments/chem/asp/saveReagents.asp"-->
    <!-- #include file="../_inclds/experiments/chem/asp/saveProducts.asp"-->
    <!-- #include file="../_inclds/experiments/chem/asp/saveSolvents.asp"-->

    <%
    connAdmTrans.commitTrans

    ' put the real JSON value back
	experimentJSON.Set "reactants", oldReactants
	experimentJSON.Set "reagents", oldReagents
	experimentJSON.Set "products", oldProducts
	experimentJSON.Set "solvents", oldSolvents

End if

Response.write("{Done:""done""}")
Response.end()

%>