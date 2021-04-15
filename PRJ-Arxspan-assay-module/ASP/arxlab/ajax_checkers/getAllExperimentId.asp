<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<%
    expId = Request.querystring("id")
    expType = Request.querystring("prefix")
    expTypeId = Request.querystring("expType")

    if expType <> "" then
        expTypeId = GetTypeId(expType)
    end if

    response.write getAllExperimentsId(expId, expTypeId)
    response.end
%>