<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<!-- #include file="../_inclds/common/asp/lib_JChem.asp"-->

<!-- #include file="../registration/_inclds/lib_reg.asp"-->
<!-- #include file="_inclds/fnc_getLocalRegNumber.asp"-->
<!-- #INCLUDE file="../_inclds/users/functions/fnc_hasAutoNumberNotebooks.asp" -->
<!-- #INCLUDE file="../_inclds/notebooks/functions/fnc_createNewNotebook.asp" -->
<%server.scriptTimeout=300%>
<%
If Not(session("hasAccordInt") And session("regRoleNumber") <= 15) Then
	response.redirect("logout.asp")
End If
%>
<%
notebookId = request.Form("notebookId")
notebookGroup = request.Form("notebookGroup")
If notebookId="0" then
	Call getconnected
	Call getconnectedadm
	Set r = createNewNotebook("",request.Form("notebookDescription"),"", request.Form("notebookGroup"))
	If r("success") then
		notebookId = r("newId")
	Else
		errorStr = r("errorStr")
	End If
	Call disconnectadm
	Call disconnect
End if

isAuthorizedNotebookUser = ownsNotebook(notebookId)
If (Not isAuthorizedNotebookUser) and (session("email") = "support@arxspan.com") Then
	isAuthorizedNotebookUser = True
End If

If request.Form("numMols") <> "" And isAuthorizedNotebookUser Then
	Call getConnectedJchemReg
	For theLoopIndex = 1 To Int(request.Form("numMols"))
		Set recz = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT structure FROM accMols WHERE id="&SQLClean(request.Form("mol_"&theLoopIndex&"_id"),"N","S")
		recz.open strQuery,jchemRegConn,3,3
		If Not recz.eof Then
			If request.Form("mol_"&theLoopIndex&"_included") = "on" Then
				'request.Form("mol_"&theLoopIndex&"_molData")
				'arr = getLocalRegNumber(request.Form("mol_"&theLoopIndex&"_molData"),true)
				arr = getLocalRegNumber(recz("structure"),true)
				cdId = arr(0)
				localRegNumber = arr(1)
				Set recz2 = server.CreateObject("ADODB.RecordSet")
				strQuery = "SELECT id FROM accMols WHERE localRegNumber="&SQLClean(localRegNumber,"T","S")& " AND notebookId="&SQLClean(notebookId,"N","S")
				recz2.open strQuery,jchemRegConn,3,3
				If recz2.eof then
					strQuery = "UPDATE accMols SET included=1,uploaded=1, "&_
						"foreignRegNumber="&SQLClean(request.Form("mol_"&theLoopIndex&"_frn"),"T","S") & "," &_
						"notebookId="&SQLClean(notebookId,"N","S") & "," &_
						"newStructure="&SQLClean(recz("structure"),"T","S") & "," &_
						"cd_id="&SQLClean(cdId,"N","S") & "," &_
						"localRegNumber="&SQLClean(localRegNumber,"T","S")& "," &_
						"projectName="&SQLClean(request.Form("projectName"),"T","S") &_
						" WHERE id="&SQLClean(request.Form("mol_"&theLoopIndex&"_id"),"N","S")
					jChemRegConn.execute(strQuery)
				End If
				recz2.close
				Set recz2 = nothing
			Else
				strQuery = "UPDATE accMols SET included=0,uploaded=1 WHERE id="&SQLClean(request.Form("mol_"&theLoopIndex&"_id"),"N","S")
				jChemRegConn.execute(strQuery)
			End If
		End If
		recz.close
		Set recz = Nothing
	Next
	Call disconnectJchemReg
End If
%>
<h1><%=requestCompoundsLabel%></h1>
<%If errorStr <> "" then%>
<span style="color:red;">
<%="Failed to create notebook: "&errorStr%>
</span>
<%else%>
<p>Your file has been processed successfully. <a href="<%=mainAppPath%>/show-notebook.asp?id=<%=notebookId%>">View notebook</a></p>
<%End if%>
<!-- #include file="../_inclds/footer-tool.asp"-->