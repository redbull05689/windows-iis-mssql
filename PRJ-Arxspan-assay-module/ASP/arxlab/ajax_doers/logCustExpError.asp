<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include file="../../_inclds/connection.asp"-->
<!-- #include file="../_inclds/common/functions/fnc_writeToAspErrors.asp"-->
<!-- #include file="../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->
<%
	userId = session("userId")
    description = request.form("description")
    page = request.form("location")

    eId = writeToAspErrors(page, description, 0)
    response.write(eId)
    response.end
%>