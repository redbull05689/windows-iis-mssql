<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<!-- #include file="../_inclds/globals.asp"-->
<%
str = "["
	Set nRec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT DISTINCT projectId,userId,name,visible,lastViewed,description,fullName FROM allProjectPermViewWithInfo WHERE userId="&SQLClean(session("userId"),"N","S")&" and visible=1 and ((accepted=1 ) or (accepted is null)) and parentprojectId is null order by lastViewed DESC"
	nRec.open strQuery,conn,3,3
	Do While Not nRec.eof
		Set nRec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT id,name FROM projects WHERE parentprojectId="&SQLClean(nRec("projectId"),"N","S")
		nRec2.open strQuery,conn,3,3
		If nRec2.eof then
			str = str& "['"&nRec("projectId")&"','"&Replace(nRec("name"),"'","\'")&"']"
		Else
			str = str& "['x','"&Replace(nRec("name"),"'","\'")&"'],"
			Do While Not nRec2.eof
				str = str& "['"&nRec2("id")&"','--"&Replace(nRec2("name"),"'","\'")&"']"
				nRec2.movenext
				If Not nRec2.eof And Not nRec.eof Then
					str = str &","
				End if
			loop
		End If
		nRec2.close
		Set nRec2 = Nothing
		nRec.movenext
		If Not nRec.eof Then
			str = str &","
		End if
	Loop
	nRec.close
	Set nRec = nothing

str = str &"]"
Call disconnectJchemReg
response.write(str)
%>