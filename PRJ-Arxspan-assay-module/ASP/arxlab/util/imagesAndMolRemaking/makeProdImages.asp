<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="_inclds/globals.asp"-->
<
server.scripttimeout = 300
%>
<%
	if session("userId") = "2" then
		Call getconnectedadm
		Set exRec = server.CreateObject("ADODB.Recordset")
		strQuery = "SELECT * from experiments"
		exRec.open strQuery,connAdm,3,3
		do while not exRec.eof
			'create a text file for the product data to be rendered by dispatch
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			set tfile=fs.CreateTextFile("c:\inbox\"&whichServer&"_"&getCompanyIdByUser(exRec("userId"))&"_"&exRec("userId")&"_"&exRec("id")&"_"&exRec("revisionNumber")&"_trash_prods.prods")
			tfile.WriteLine(exRec("molData"))
			tfile.close
			set tfile=nothing
			set fs=nothing

			exRec.movenext
		loop
	end if
%>