<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%Server.ScriptTimeout=108000%>
<%
sectionId = "show-userReport"
subsectionId = "show-userReport"
%>
<!-- #include file="../_inclds/globals.asp"-->

<%
sectionId = "tool"
%>

<%
Call getconnected
%>
<!-- #include file="../_inclds/header-tool.asp"-->
<!-- #include file="../_inclds/nav_tool.asp"-->
<link href="<%=mainCSSPath%>/experiment.css?<%=jsRev%>" rel="stylesheet" type="text/css" MEDIA="screen">	
<style type="text/css">@import url(<%=mainAppPath%>/js/jscalendar/calendar-win2k-1.css);</style>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/lang/calendar-en.js?<%=jsRev%>"></script>
<script type="text/javascript" src="<%=mainAppPath%>/js/jscalendar/calendar-setup.js?<%=jsRev%>"></script>

<%
If canSeeShowUserReport then
%>

<%
If request.Form("formSubmit") <> "" Then
	companyId = request.form("companyId")
	startDate = request.Form("startDate")
	endDate = request.Form("endDate")
	dateUnit = request.Form("dateUnit")
	strSearch = request.Form("strSearch")
End if
%>

<form action="<%=mainAppPath%>/table_pages/show-userReport.asp" method="post">
	<label for="companyId">Company</label><br/>
	<select id="companyId" name="companyId">
	<%
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM companies"
	rec.open strQuery,conn,3,3
	Do While Not rec.eof
		%><option value="<%=rec("id")%>"<%If companyId=rec("id") then%> SELECTED<%End if%>><%=rec("name")%></option><%
		rec.movenext
	Loop
	rec.close
	Set rec = nothing
	%>
	</select><br/>
	<label for="startDate">Start Date:</label><br/>
	<input name="startDate" id="startDate" type="text" value="<%=startDate%>" autocomplete="off">
	<script type="text/javascript">
	Calendar.setup({
		inputField  : "startDate",         // ID of the input field
		ifFormat    : "%m/%d/%Y",    // the date format
		showsTime   : false,
		timeFormat  : "12",
		electric    : false
	});
	</script><br/>
	<label for="endDate">End Date:</label><br/>
	<input name="endDate" id="endDate" type="text" value="<%=endDate%>" autocomplete="off">
	<script type="text/javascript">
	Calendar.setup({
		inputField  : "endDate",         // ID of the input field
		ifFormat    : "%m/%d/%Y",    // the date format
		showsTime   : false,
		timeFormat  : "12",
		electric    : false
	});
	</script><br/>
	<label for="dateUnit">Date Unit:</label><br/>
	<select id="dateUnit" name="dateUnit">
		<option value="d"<%If dateUnit="d" then%> SELECTED<%End if%>>Day</option>
		<option value="yyyy"<%If dateUnit="yyyy" then%> SELECTED<%End if%>>Year</option>
		<option value="q"<%If dateUnit="q" then%> SELECTED<%End if%>>Quarter</option>
		<option value="m"<%If dateUnit="m" then%> SELECTED<%End if%>>Month</option>
		<option value="y"<%If dateUnit="y" then%> SELECTED<%End if%>>Day of year</option>
		<option value="w"<%If dateUnit="w" then%> SELECTED<%End if%>>Weekday</option>
		<option value="ww"<%If dateUnit="ww" then%> SELECTED<%End if%>>Weak of year</option>
		<option value="h"<%If dateUnit="h" then%> SELECTED<%End if%>>Hour</option>
		<option value="n"<%If dateUnit="n" then%> SELECTED<%End if%>>Minute</option>
		<option value="s"<%If dateUnit="s" then%> SELECTED<%End if%>>Second</option>
	</select><br/>
	<label for="endDate">Filter:</label><br/>
	<input name="strSearch" id="strSearch" type="text" value="<%=strSearch%>"><br/>
	<input type="submit" name="formSubmit" value="GO">
</form>

<%
If request.Form("formSubmit") <> "" Then
	logViewName = getDefaultSingleAppConfigSetting("logViewName")
	Call getconnectedadm
	strQuery = "INSERT into billingReports(name) output inserted.id as newId values('')"
	Set rs = connAdm.execute(strQuery)
	reportId = CStr(rs("newId"))
	Call getconnectedlog
	Set rec = server.CreateObject("ADODB.RecordSet")
	strQuery = "SELECT * FROM usersView WHERE companyId="&SQLClean(companyId,"N","S")
	If strSearch <> "" then
		strQuery = strQuery & " AND (companyName like "&SQLClean(strSearch,"L","S")&" or email like "&SQLClean(strSearch,"L","S")&" or firstName like "&SQLClean(strSearch,"L","S")&" or lastName like "&SQLClean(strSearch,"L","S")&")"
	End If
	strQuery = strQuery &" ORDER BY firstName,lastName"
	rec.open strQuery,conn,3,3
	totalTimeEnabled = 0
	totalTimeDisabled = 0
	uCount = 0
	Do While Not rec.eof
		uCount = uCount + 1
		If IsNull(rec("dateOfSignup")) Then
			dateCreated = CDate("Jan 1, 1902")
		else
			dateCreated = CDate(Split(rec("dateOfSignup")," ")(0))
		End if
		timeDisabled = 0
		timeEnabled = 0
		extraText = ""
		%><h2><%=uCount%>&nbsp;<%=rec("firstName")%>&nbsp;<%=rec("lastName")%>&nbsp;:&nbsp;<%=rec("email")%>&nbsp;:&nbsp;<%=rec("id")%></h2>
		<%extraText = extraText & "Date Created: "&dateCreated&"<br/>"%>
		<%
		If DateDiff(dateUnit,dateCreated,startDate) < 0 Then
			timeDisabled = timeDisabled + DateDiff(dateUnit,dateCreated,startDate)*-1
			timeEnabled = DateDiff(dateUnit,dateCreated,startDate)
		End if
		Set rec2 = server.CreateObject("ADODB.RecordSet")
		strQuery = "SELECT * from "&logViewName&" WHERE (cast(dateSubmittedServer as DATE) between "&SQLClean(startDate,"T","S")&" and "&SQLClean(endDate,"T","S")&") and (actionId=22 or actionId=23) and extraId="&SQLClean(rec("id"),"N","S")
		rec2.open strQuery,connLog,3,3
		If rec2.eof Then
			Set rec3 = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * from "&logViewName&" WHERE (cast(dateSubmittedServer as DATE) between "&SQLClean("1/2/1900","T","S")&" and "&SQLClean(endDate,"T","S")&") and (actionId=23) and extraId="&SQLClean(rec("id"),"N","S")&" ORDER BY dateSubmittedServer DESC"
			rec3.open strQuery,connLog,3,3
			If rec3.eof Then
				timeEnabled = timeEnabled + DateDiff(dateUnit,startDate,endDate)
			Else
				extraText = extraText & "User Disabled: "&CDate(rec3("dateSubmittedServer"))&"<br/>"
				timeDisabled = timeDisabled + DateDiff(dateUnit,startDate,endDate)
			End If
			rec3.close
			Set rec3 = nothing
		Else
		''there are some log entries in the date range
			counter = 0
			Do While Not rec2.eof
				If counter = 0 Then
					If rec2("actionId") = 23 Then
						timeEnabled = timeEnabled + DateDiff(dateUnit,startDate,CDate(rec2("dateSubmittedServer")))
						extraText = extraText & "User Disabled: "&CDate(rec2("dateSubmittedServer"))&"<br/>"
					End If
					If rec2("actionId") = 22 Then
						timeDisabled = timeDisabled + DateDiff(dateUnit,startDate,CDate(rec2("dateSubmittedServer")))
						extraText = extraText & "User Enabled: "&CDate(rec2("dateSubmittedServer"))&"<br/>"
					End if
				Else
					If rec2("actionId") = 23 Then
						timeEnabled = timeEnabled + DateDiff(dateUnit,lastDate,CDate(rec2("dateSubmittedServer")))
						extraText = extraText & "User Disabled: "&CDate(rec2("dateSubmittedServer"))&"<br/>"
					End If
					If rec2("actionId") = 22 Then
						timeDisabled = timeDisabled + DateDiff(dateUnit,lastDate,CDate(rec2("dateSubmittedServer")))
						extraText = extraText & "User Enabled: "&CDate(rec2("dateSubmittedServer"))&"<br/>"
					End if
				End if
				counter = counter + 1

				lastDate = CDate(rec2("dateSubmittedServer"))
				If rec2("actionId") = 23 Then
					lastState = "disabled"
				End If
				If rec2("actionId") = 22 Then
					lastState = "enabled"
				End if
				rec2.movenext
			Loop
			If lastState="enabled" Then
				timeEnabled = timeEnabled + DateDiff(dateUnit,lastDate,CDate(endDate))
			End If
			If lastState="disabled" Then
				timeDisabled = timeDisabled + DateDiff(dateUnit,lastDate,CDate(endDate))
			End if
		End If
		rec2.close
		Set rec2 = nothing
		%>
		<br/>
		Time Enabled: <%=timeEnabled%><br/>
		Time Disabled: <%=timeDisabled%><br/>
		<%
		strQuery = "INSERT INTO billingReportsData(billingReportId,userId,dateUnit,userName,email,timeEnabled,timeDisabled,extraText) values("&_
				SQLClean(reportId,"N","S") &","&_
				SQLClean(rec("id"),"N","S") &","&_
				SQLClean(dateUnit,"T","S") &","&_
				SQLClean(rec("firstName")&" "&rec("lastName"),"T","S") &","&_
				SQLClean(rec("email"),"T","S") &","&_
				SQLClean(timeEnabled,"N","S") &","&_
				SQLClean(timeDisabled,"N","S") &","&_
				SQLClean(extraText,"T","S") &")"
		connAdm.execute(strQuery)
		%>
		<%
		totalTimeEnabled = totalTimeEnabled + timeEnabled
		totalTimeDisabled = totalTimeDisabled + timeDisabled
		rec.movenext
	loop
	%><br/><br/><h1>Totals</h1>
	Time Enabled: <%=totalTimeEnabled%><br/>
	Time Disabled: <%=totalTimeDisabled%><br/>
	<%
	Call disconnectlog
	Call disconnectadm
	response.redirect(mainAppPath&"/table_pages/show-userReportData.asp?reportId="&reportId)
End if
%>

<%End if%>
<!-- #include file="../_inclds/common/html/submitFrame.asp"-->
<!-- #include file="../_inclds/footer-tool.asp"-->