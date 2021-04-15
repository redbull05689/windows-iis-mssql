<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
if session("companyId") = "1" and session("roleNumber") <= 1 then
	Set D = new LD
	D.addPair "name","groupId"
	D.addPair "id","groupId"
	Set L = new LD
	Call getconnected
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "select * from groups WHERE companyId="&SQLClean(request.querystring("id"),"N","S")&" ORDER BY name"
	rec.open strQuery,conn,3,3
	Set D2 = new LD
	D2.addPair "value","0"
	D2.addPair "text","--SELECT--"
	L.addItem D2
	Set D2 = nothing
	Do While Not rec.eof
		Set D2 = new LD
		D2.addPair "value",rec("id")
		D2.addPair "text",rec("name")
		L.addItem D2
		Set D2 = nothing
		rec.movenext
	loop
	Call disconnect
	D.addPair "options",L
	response.write(D.serialize("js"))
	Set L = Nothing
	Set D = Nothing
end if
%>