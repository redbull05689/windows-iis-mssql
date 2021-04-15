<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
Function callStoredProcedure(procedureName, jsonArgs, isAjax)
	Call getconnected
	On Error Resume Next
	Set cmd = Server.CreateObject("ADODB.Command")
	Set myConn = conn
	cmd.ActiveConnection = myConn
	cmd.CommandType = adCmdStoredProc
	cmd.CommandText = procedureName

	Set outParam = cmd.CreateParameter(returnName, adInteger, adParamReturnValue, , 0)
	cmd.Parameters.Append outParam

	' Parameter 0 must be the stored procedure return code
	For Each param In jsonArgs.keys()
		Set paramSpecs = JSON.parse(jsonArgs.Get(param))
		paramName = "@"&param
		paramType = paramSpecs.Get("type")
		paramValue = paramSpecs.Get("value")
		'response.write("paramName: " & paramName & " paramValue: " & paramValue & " paramType: " & paramType & "<br>")
		
		Set inParam = cmd.CreateParameter(paramName, paramType, adParamInput, -1, paramValue)
		cmd.Parameters.Append inParam
	Next

	Set procOutput = cmd.Execute

	errorCount = 0
	For Each objErr in myConn.Errors
		If errorCount = 0 And isAjax Then
			response.write("<div id='resultsDiv'>")
		End If
		
		response.write("An error has occurred. Please contact support@arxspan.com and provide the error description: ")
		response.write(objErr.Description)
		errorCount = errorCount + 1
	Next
	
	If errorCount = 0 Then
		callStoredProcedure = procOutput.GetRows()
		if isEmpty(callStoredProcedure) Then
			callStoredProcedure = outParam.Value
		End If
	Else
		callStoredProcedure = -1
		If isAjax Then
			response.write("</div>")
		End If
		response.end()
	End If
	
	myConn.Close
	On Error Goto 0
	Call disconnect
End Function

Sub addStoredProcedureArgument(paramList, paramName, paramType, paramValue)
	Set newArg = JSON.parse("{}")	
	newArg.Set "value", paramValue
	newArg.Set "type", paramType
	paramList.Set paramName, JSON.stringify(newArg)
End Sub
%>