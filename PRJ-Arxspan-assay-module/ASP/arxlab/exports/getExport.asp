<% Server.ScriptTimeout = 60000 %>
<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
Call getconnectedAdm
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, endFile FROM exports WHERE userId="&SQLClean(session("userId"),"N","S") & " AND status=2 AND endFile LIKE '%bulkExportTemp\{companyId}\%'"
strQuery = Replace(strQuery, "{companyId}", SQLClean(session("companyId"),"N","S"))
rec.open strQuery,connAdm,3,3
If Not rec.eof Then
	filepath = rec("endFile")
	connAdm.execute("DELETE FROM exports WHERE id="&SQLClean(rec("id"),"N","S"))
	If filepath <> "" Then
		t = Split(filepath,"\")
		filename = t(UBound(t))
		set fs=Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists(filepath) Then
			Set adoStream = CreateObject("ADODB.Stream")
			adoStream.Open()
			response.contenttype="application/octet-stream"
			response.addheader "contenttype","application/octet-stream"			
			response.addheader "Content-Disposition", "attachment; " & "filename=""" & filename &""""

			adoStream.Type = 1  
			adoStream.LoadFromFile(filepath)  

				Set fs=Server.CreateObject("Scripting.FileSystemObject")
				Set f=fs.GetFile(filepath)
				dataSize = f.size
				Set f = nothing
				Set fs = Nothing
				Response.AddHeader "Content-Length", dataSize

				dataPosition = 0
				chunkSize = 1024*1024*4
				do while dataPosition < dataSize
				Response.BinaryWrite adoStream.Read(chunkSize)
				Response.flush
				dataPosition = dataPosition + chunkSize
				loop

			adoStream.Close: Set adoStream = Nothing  
			Set fs = server.CreateObject("Scripting.FileSystemObject")
			fs.DeleteFile(filePath)
			Set fs = nothing
			Response.End
		Else
			response.write("file does not exist")
			response.end
		End if
	End if
End if
%>