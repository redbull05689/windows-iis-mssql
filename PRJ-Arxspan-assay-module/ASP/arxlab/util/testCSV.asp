<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->

<%
if session("email") = "support@arxspan.com" then

		Set csvConn = CreateObject("ADODB.Connection")
		csvConn.Open "Provider=Microsoft.ACE.OLEDB.12.0;" & _
          "Data Source=c:\;" & _
          "Extended Properties=""text;ImportMixedTypes=Text;HDR=YES;FMT=CSVDelimeted"""
		
		Set rec = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * FROM [test.csv]"
		rec.open strQuery,csvConn,3,3
		rows = rec.getRows()
		rowCount = rec.recordCount
		
		colCount = rec.fields.count

		rec.close
		Set rec = nothing
		csvConn.close
	For i = 0 To rowCount - 1
		For j = 0 To colCount -1
			response.write(rows(j,i)&"<br/><br/>")
		next
	next
end if
%>