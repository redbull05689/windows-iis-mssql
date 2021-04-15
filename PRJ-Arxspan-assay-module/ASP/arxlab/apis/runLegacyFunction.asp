<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%isApiPage = true%>
<% Response.AddHeader "Access-Control-Allow-Origin", "*"%>
<%data = request.form%>
<!-- #include virtual="/arxlab/_inclds/globals_apis.asp" -->
<!-- #include file="../_inclds/globals.asp"-->
<%
If request.servervariables("REMOTE_ADDR") <> "8.20.189.170" And request.servervariables("REMOTE_ADDR") <> "8.20.189.168" And request.servervariables("REMOTE_ADDR") <> "8.20.189.169" And request.servervariables("REMOTE_ADDR") <> "8.20.189.188" And request.servervariables("REMOTE_ADDR") <> "8.20.189.16" then
	response.redirect("/login.asp")
End if

' For now we have to manually add session variables that we need for any function that runs through this file
' Ideally this would somehow simulate a user login based on userId and company API key supplied
' Look out for session collisions... Decent solution would be to make elnApi always start a brand new session every time it uses restCall... The fact ASP is single-threaded per session should mean there's no security threat though - it'll just be delayed...

companyId = request.querystring("companyId")
userId = request.querystring("userId")

Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT * FROM users WHERE enabled=1 AND companyId="&SQLClean(companyId,"N","S")&" AND id="&SQLClean(userId,"N","S")

rec.open strQuery,conn,3,3
If Not rec.eof Then

	loginUser(rec("id"))

	' Call the function
	functionName = Request.querystring("functionName")
	functionParameter1 = Request.querystring("p1")
	functionParameter2 = Request.querystring("p2")
	functionParameter3 = Request.querystring("p3")
	functionParameter4 = Request.querystring("p4")
	functionParameter5 = Request.querystring("p5")
	functionParameter6 = Request.querystring("p6")
	functionParameter7 = Request.querystring("p7")
	functionParameter8 = Request.querystring("p8")
	functionParameter9 = Request.querystring("p9")
	functionParameter10 = Request.querystring("p10")
	functionParameterCount = CStr(Request.querystring("functionParameterCount"))

	Dim FP : Set FP = GetRef(functionName)

	functionResponse = "TEST" & functionParameterCount
	if functionParameterCount = "1" then
		functionResponse = FP(functionParameter1)
	elseif functionParameterCount = "2" then
		functionResponse = FP(functionParameter1, functionParameter2)
	elseif functionParameterCount = "3" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3)
	elseif functionParameterCount = "4" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3, functionParameter4)
	elseif functionParameterCount = "5" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3, functionParameter4, functionParameter5)
	elseif functionParameterCount = "6" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3, functionParameter4, functionParameter5, functionParameter6)
	elseif functionParameterCount = "7" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3, functionParameter4, functionParameter5, functionParameter6, functionParameter7)
	elseif functionParameterCount = "8" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3, functionParameter4, functionParameter5, functionParameter6, functionParameter7, functionParameter8)
	elseif functionParameterCount = "9" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3, functionParameter4, functionParameter5, functionParameter6, functionParameter7, functionParameter8, functionParameter9)
	elseif functionParameterCount = "10" then
		functionResponse = FP(functionParameter1, functionParameter2, functionParameter3, functionParameter4, functionParameter5, functionParameter6, functionParameter7, functionParameter8, functionParameter9, functionParameter10)
	end if
	response.write functionResponse

End If
%>