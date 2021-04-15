<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isAjax=true%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/experiments/common/functions/fnc_convertToCDXML.asp"-->

<%
    ' Endpoint that JS can hit that attempts to convert the given moldata string into CDXML.
    moldata = Request.Form("moldata")
    format = getFileFormat(moldata)

    cdxmlData = moldata

    ' If the format doesn't seem to be CDXML, then run it through JLo's service.
    if format <> "cdxml" then
        cdxmlData = convertToCDXML(moldata, format)
    end if

    response.write cdxmlData
    response.end
%>