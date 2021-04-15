<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%'This will Delete then Update the elasticSearch datamappings, we need to call them only once (and you will need to reindex everything again after you run this)
If session("companyId")="1" Or session("email")="support@arxspan.com" or whichServer="DEV" then
    
    ' Delete the indexes
    ' mappingJson = "{}"
    ' call callElastic("DELETE",elasticURL & "/anal?pretty",mappingJson)

    ' mappingJson = "{}"
    ' call callElastic("DELETE",elasticURL & "/bio?pretty",mappingJson)

    ' mappingJson = "{}"
    ' call callElastic("DELETE",elasticURL & "/chem?pretty",mappingJson)

    ' mappingJson = "{}"
    ' call callElastic("DELETE",elasticURL & "/free?pretty",mappingJson)

    ' ' Create them
    ' mappingJson = "{}"
    ' call callElastic("PUT",elasticURL & "/anal?pretty",mappingJson)

    ' mappingJson = "{}"
    ' call callElastic("PUT",elasticURL & "/bio?pretty",mappingJson)

    ' mappingJson = "{}"
    ' call callElastic("PUT",elasticURL & "/chem?pretty",mappingJson)

    ' mappingJson = "{}"
    ' call callElastic("PUT",elasticURL & "/free?pretty",mappingJson)

    ' ' Now update the mappings.
    ' mappingJson = "{""properties"": {""dateCreated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""dateUpdated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""history"": {""type"": ""nested""}}}"
    ' call callElastic("PUT",elasticURL & "/anal?pretty",mappingJson)

    ' mappingJson = "{""properties"": {""dateCreated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""dateUpdated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""history"": {""type"": ""nested""}}}"
    ' call callElastic("PUT",elasticURL & "/bio?pretty",mappingJson)

    ' mappingJson = "{""properties"": {""dateCreated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""dateUpdated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""history"": {""type"": ""nested""}}}"
    ' call callElastic("PUT","http://10.10.10.41:9201" & "/chem/_mapping?pretty",mappingJson)

    ' mappingJson = "{""properties"": {""dateCreated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""dateUpdated"": {""type"": ""date"",""format"": ""MM/dd/yyyy HH:mm:ss a""},""history"": {""type"": ""nested""}}}"
    ' call callElastic("PUT",elasticURL & "/free?pretty",mappingJson)
end if

function callElastic(verb, url, body)
    Dim objXmlHttp
    Set objXmlHttp = Server.CreateObject("Msxml2.ServerXMLHTTP")
    objXmlHttp.open verb, url, True
    objXmlHttp.setRequestHeader "Content-Type", "application/json"
    objXmlHttp.send body
	objXmlHttp.waitForResponse(60)

    Dim ResponseString
    ResponseString = split(objXmlHttp.responseText, vblf)
    Set objXmlHttp = Nothing

    for each x in ResponseString
        response.write(x & "<br />")
    next
end function




%>