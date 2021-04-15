<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%Response.Buffer=False%>
<%Server.scriptTimeout = 180000%>
<%
sectionId = "tool"
subSectionId = "productsSD"
pageTitle = "Arxspan Products SD Download"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
If Not (session("roleNumber") = "1" And session("hasProductsSD") <> "0") Then
	response.redirect(loginScriptName)
End if
%>
<%

Function writeChunk(theData)
    response.write(theData)
    response.flush()
End Function

Function shouldWriteChunk(theData, chunkSize)
    'write the response in 1mb chunks - I was getting a buffer overrun in cases where trying to return a lot of data
    'chunkSize = 1000000
    dataLen = Len(theData)

    If dataLen >= chunkSize Then
        shouldWriteChunk = True
    Else
        shouldWriteChunk = False
    End If
End Function

displayNames = "Name,RegistrationId,Molecular Formula,Molecular Weight,Actual Mass,Actual Moles,Yield,Purity,Theoretical Mass,Theoretical Moles,Equivalents,Measured Mass,Tab Name"
dbNames = "name,regId,molecularFormula,molecularWeight,actualMass,actualMoles,yield,purity,theoreticalMass,theoreticalMoles,equivalents,measuredMass,trivialName"
displayNames = Split(displayNames,",")
dbNames = Split(dbNames,",")
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM productsView WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND ((molData3000 is not null and cast(molData3000 as varchar(8000))<>'') or (molData is not null and cast(molData as varchar(8000))<>''))"
rec.open strQuery,conn,1,1

sdFileStr = ""
response.contenttype="text/plain"
response.addheader "ContentType","text/plain"
response.addheader "Content-Disposition", "attachment; " & "filename=all-products.sdf"

Do While Not rec.eof
	If IsNull(rec("molData3000")) Or rec("molData3000")="" Then
		molData = rec("molData")
	else
		molData = rec("molData3000")
	End If
	molDataLines = Split(molData,vbcrlf)
	If UBound(molDataLines) = 0 Then
		molDataLines = Split(molData,vbcr)
	End If
	If UBound(molDataLines) = 0 Then
		molDataLines = Split(molData,vblf)
	End If
	If UBound(molDataLines) >= 3 Then
		If Not isInteger(Trim(Left(molDataLines(3),3))) Then
			molData = vbcrlf & molData
		End If
	End If
	If Right(molData,1) <> vbcr And Right(molData,1) <> vblf And Right(molData,1) <> vbcrlf Then
		molData = molData & vbcrlf
	End if
	sdFileStr = sdFileStr & molData
	For i = 0 To UBound(dbNames)
		sdFileStr = sdFileStr & ">  <"&displayNames(i)&">"&vbcrlf&rec(dbNames(i))&vbcrlf&vbcrlf
	next
    
    Set rec2 = server.CreateObject("ADODB.RecordSet")
    strQuery = "SELECT name FROM allExperiments WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND experimentType="&rec("experimentType")&" AND legacyId="&rec("experimentId")
    rec2.open strQuery,conn,1,1
        If not rec2.eof Then
            sdFileStr = sdFileStr & ">  <experiment_name>"&vbcrlf&rec2("name")&vbcrlf&vbcrlf
        End If
    rec2.Close
    Set rec2 = Nothing

	sdFileStr = sdFileStr & "$$$$" & vbcrlf
    
    If shouldWriteChunk(sdFileStr, 1000000) = True Then
        writeChunk(sdFileStr)
        sdFileStr = ""
    End If
	rec.movenext
Loop
rec.close
Set rec = nothing
Call disconnect
response.write(sdFileStr)
response.end()
%>