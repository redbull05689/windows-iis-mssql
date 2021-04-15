<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
regEnabled = true
subsectionId = "combo-custom-fields"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
Call getconnectedJchemReg
If Not session("regRegistrar") Or session("regRegistrarRestricted") Then
	response.redirect(mainAppPath&"/static/error.asp")
End If

strQuery = ""
strQuery = strQuery & "INSERT INTO comboCustomFields(visible) output inserted.id as newId values(1)"
Set rs = jchemRegConn.execute(strQuery)
theId = CStr(rs("newId"))
Call disconnectJchemReg
response.redirect("customFields.asp?groupId="&theId&"&set=1")
%>