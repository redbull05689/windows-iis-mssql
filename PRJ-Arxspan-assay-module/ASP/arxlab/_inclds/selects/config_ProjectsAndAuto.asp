<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../globals.asp"-->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->

<%   
    ' Fetches the configs needed in order to determine whether to display projects and or Auto Notebook names. Outputs a json
	Set nRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT autoNotebookNumber,requireProjectLink,requireProjectLinkForNB FROM companies WHERE id="&SQLClean(session("companyId"),"N","S")&"" 
	nRec.open strQuery,conn,3,3
        Set auto = JSON.parse("[]")

        If Not nRec.eof Then
            autoNotebookNumber = nRec("autoNotebookNumber")
            requireProjectLink = nRec("requireProjectLink")
            requireProjectLinkForNB = nRec("requireProjectLinkForNB")

                Set displayConfig = JSON.parse("{}")
                    displayConfig.set "autoNotebookNumber", autoNotebookNumber
                    displayConfig.set "requireProjectLink", requireProjectLink
                    displayConfig.set "requireProjectLinkForNB", requireProjectLinkForNB
        End If 
    nRec.close
    
    auto.push(displayConfig)
    Set nRec = nothing
    response.write JSON.stringify(auto)    
    response.end
%>
