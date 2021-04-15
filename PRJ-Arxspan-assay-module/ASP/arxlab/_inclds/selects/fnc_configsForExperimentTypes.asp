
<%
    ' func to fetch variables from session that determine what exp types are active or not
    function configsForExperimentTypes() 
        Set configArr = JSON.parse("[]")

            hasChemistry = session("hasChemistry")
            hideNonCollabExperiments = session("hideNonCollabExperiments")
            hasMUFExperiment = session("hasMUFExperiment")

        Set configObj = JSON.parse("{}")
            configObj.set "hasChemistry", hasChemistry
            configObj.set "hideNonCollabExperiments", hideNonCollabExperiments
            configObj.set "hasMUFExperiment", hasMUFExperiment
        configArr.push(configObj)
        
        configsForExperimentTypes = JSON.stringify(configArr)
    End function
%>