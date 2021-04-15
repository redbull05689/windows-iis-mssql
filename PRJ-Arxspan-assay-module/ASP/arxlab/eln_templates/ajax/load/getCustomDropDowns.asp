<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
'Dim Conn
%>
<!-- #include file="../../../_inclds/escape_and_filter/functions/fnc_SQLClean.asp"-->
<!-- #include file="../../../_inclds/__whichServer.asp"-->
<%
Call getconnected
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT id, name, heading FROM templateDropDowns WHERE companyId="&SQLClean(session("companyId"),"N","S")& " ORDER BY name ASC"
rec.open strQuery,conn,3,3
arrStr = "["
counter = 0
Do While Not rec.eof
	arrStr = arrStr & "['"&counter&"','"&Replace(Replace(rec("name"),"'","\'"),vbcrlf,"")&"','"&Replace(Replace(rec("name"),"'","\'"),vbcrlf,"")&"','"
	arrStr = arrStr & "<a class=""autoFill"" heading="""&rec("heading")&""" href=""javascript:void(0)"" type=""static"" " 
	Set rec2 = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT value FROM templateDropDownOptions WHERE parentId="&SQLClean(rec("id"),"N","S")
	rec2.open strQuery,conn,3,3
	counter2 = 0
	Do While Not rec2.eof
		counter2 = counter2 + 1
		arrStr = arrStr & "option_"&counter2&"="""&Replace(Replace(rec2("value"),"""","&quot;"),"'","&#39;")&""" "
		rec2.movenext
	Loop
	rec2.close
	Set rec2 = Nothing
	arrStr = arrStr & " numoptions="""&counter2&""">" & rec("heading") & "</a>']"
	rec.movenext
	counter = counter + 1
	If Not rec.eof Then 
		arrStr = arrStr & ","
	End if
loop
arrStr = arrStr & "]"
response.write(arrStr)
Call disconnect
%>