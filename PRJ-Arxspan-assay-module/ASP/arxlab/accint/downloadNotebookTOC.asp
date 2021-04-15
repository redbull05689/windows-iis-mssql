<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%
sectionId="reg"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
notebookId = request.querystring("notebookId")
notebookName = request.querystring("notebookName")

set fs=Server.CreateObject("Scripting.FileSystemObject")

if canReadNotebook(notebookId,session("userId")) Then
	fileStr = ""
	Call getconnectedJchemReg
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM accMols WHERE notebookId="&SQLClean(notebookId,"N","S")&" AND included=1"
	rec.open strQuery,jchemRegConn,3,3
	Do While Not rec.eof
		structure = rec("newStructure")
		localRegNumber = rec("localRegNumber")
		project = rec("projectName")
		If Left(structure,2) <> vbcrlf Then
			structure = structure & vbcrlf
		End If
		fileStr = fileStr & structure
		fileStr = fileStr & ">  <eln_reg_number>"&vbcrlf
		fileStr = fileStr & localRegNumber & vbcrlf & vbcrlf
		'fileStr = fileStr & ">  <project_name>"&vbcrlf
		'fileStr = fileStr & project & vbcrlf & vbcrlf
		fileStr = fileStr & ">  <notebook_name>"&vbcrlf
		fileStr = fileStr & notebookName & vbcrlf & vbcrlf
		fileStr = fileStr & "$$$$"&vbcrlf
		rec.movenext
	Loop
	Call disconnectJchemReg
		Response.AddHeader "Content-Disposition", "attachment; filename="&notebookName&"-TOC.sdf"
        'Response.AddHeader "Content-Length", Len(fileStr)
        Response.ContentType = "text/plain"
		response.write(fileStr)
End If
%>