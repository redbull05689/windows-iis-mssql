<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId = "create-notebook"
%>
<!-- #include file="../_inclds/globals.asp"-->
<% Response.CacheControl = "no-cache" %>
<% Response.AddHeader "Pragma", "no-cache" %>
<% Response.Expires = -1 %>

<!-- #INCLUDE file="../_inclds/users/functions/fnc_hasAutoNumberNotebooks.asp" -->
<!-- #INCLUDE file="../_inclds/notebooks/functions/fnc_createNewNotebook.asp" -->
<%
	pageTitle = "Arxspan Create Notebook"
%>
<%
Call getconnected
autoNumberNotebooks = hasAutoNumberNotebooks()
If request.Form <> "" Then
	notebookName = request.Form("notebookName")
	notebookDescription = request.Form("notebookDescription")
	Call getconnected
	Call getconnectedadm
	Set r = createNewNotebook(request.Form("notebookName"),request.Form("notebookDescription"),request.Form("linkProjectId"), request.Form("notebookGroup"))
	set outJson = JSON.parse("{}")
	If r("success") then
		outJson.set "notebookId", r("newId")
		outJson.set "notebookName", r("newName")
	Else
		outJson.set "errorStr", r("errorStr")
		outJson.set "errorFields", r("efields")
	End If
	response.write JSON.stringify(outJson)
	Call disconnectadm
End if
%>