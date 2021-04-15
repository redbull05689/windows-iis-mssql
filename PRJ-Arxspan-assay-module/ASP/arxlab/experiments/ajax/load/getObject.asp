<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../../../_inclds/globals.asp"-->
<%
Response.CodePage = 65001
Response.Charset = "UTF-8"
'(form_name,display_text,form_type)
experimentId = request.querystring("id")
experimentType = "1"
revisionId = request.querystring("revisionId")
obType = request.querystring("type")
number = request.querystring("number")
userEnteredFields = request.querystring("userenteredfields")
firstLoad = request.querystring("firstLoad")
onSave = request.querystring("onsave")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT userId FROM experiments WHERE id=" & SQLClean(experimentId,"N","S")
rec.open strQuery,conn,3,3
If Not rec.eof then
	If session("userId") = rec("userId") Then
		ownsExp = True
	Else
		ownsExp = false
	End if
Else
	ownsExp = false
End If
%>
<%If revisionId = "" then%>
<!-- #include file="../../../_inclds/experiments/common/asp/getExperimentJSON.asp"-->
<%Else
	Set experimentJSON = JSON.parse("{}")
%>
<%End if%>
<%

Function draftSet(theKey,theVal)
	theValue = theVal
	If Not ownsExp Then
		draftSet = theValue		
	ElseIf session("useMarvin") then
		' if the user entered the data, or its a fresh page load, or we just saved, just grab everything from the ExpeirmentJSON
		if onSave = "true" then
			experimentJSON.Set theKey, theValue
			draftSet = theValue
		else
			' For marvin, we need to update the json durring draft saves with new info from Marvin
			experimentJSON.Set theKey, theValue
			draftSet = theValue
		end if
	else	
		If isDraft Then
			If experimentJSON.exists(theKey) then
				draftSet = experimentJSON.Get(theKey)
			Else
				experimentJSON.Set theKey, theValue
				draftSet = theValue
			End if
		Else
			experimentJSON.Set theKey, theValue
			draftSet = theValue
		End if
	End if
End Function

If obType <> "Solvent" then
	HTML = getObjectForm(experimentId,revisionId,obType,number,false,false,3,false)
else
	HTML = getObjectForm(experimentId,revisionId,obType,number,false,false,1,false)
End if
response.write(HTML)
%>
<!-- #include file="../../../_inclds/experiments/common/asp/saveExperimentJSON.asp"-->