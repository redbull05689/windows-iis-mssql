<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="decodeFunctions.asp"-->

<%
    ' This is an endpoint that takes an entity type code and a list of IDs and retrieves the metadata
    ' needed to properly parse the data.

    ' Take the entity information out of the querystring and convert to a number.
    objectTypeCd = CInt(request.form("objectTypeCd"))
    
    ' Get the list of IDs from the request.
    set objectIdList = JSON.parse(request.form("objectIdList"))

    ' Setup the output array.
    set outputArr = JSON.parse("[]")

    ' Now iterate through the input object IDs.
    for i=0 to objectIdList.length - 1
        ' Convert the ID into a long, then run the ID and the type code through the decode function and push
        ' the results to the output array.
        id = CLng(objectIdList.get(i))
        outputArr.push decode(id, objectTypeCd)
    next

    ' Wrap outputArr in brackets (thanks ASP) and write that out.
    response.write "[" & outputArr & "]"
    response.end

%>