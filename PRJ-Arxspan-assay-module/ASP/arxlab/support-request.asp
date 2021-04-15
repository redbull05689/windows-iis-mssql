<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%regEnabled=true%>
<%
sectionId = "dashboard"
%>
<!-- #include file="_inclds/globals.asp"-->
<% Response.CacheControl = "no-cache" %>
<% Response.AddHeader "Pragma", "no-cache" %>
<% Response.Expires = -1 %>

<!--#include file="_inclds/validation/functions/sub_Required_Form_Fields.asp"-->
<!--#include file="_inclds/validation/functions/sub_ErrorChkText.asp"-->
<!--#include file="_inclds/validation/functions/fnc_validate_phoneZipEmail.asp"-->
<%
	sectionID = "tool"
	subSectionID="dashboard"
	terSectionID=""

	pageTitle = "Arxspan Support Request"
	metaD=""
	metaKey=""

%>
<%
If request.querystring("searchButton") <> "" Then
	notebookId = request.querystring("notebookId")
	collection = request.querystring("collection")
	statusId = request.querystring("statusId")
	sortBy = request.querystring("sortBy")
	sortDir = request.querystring("sortDir")

	If Not isinteger(notebookId) Then
		notebookId = 0
	Else
		notebookId = CInt(notebookId)
	End If
	If Not isinteger(statusId) Then
		statusId = 0
	Else
		statusId = CInt(statusId)
	End If

	If sortBy = "" Then
		sortBy = "dateUpdated"
		sortDir = "DESC"
	End If
	If sortDir = "" Then
		sortDir = "ASC"
	End if
	
	strQuery = "SELECT * FROM experimentView WHERE 1=1"
	If session("role") <> "admin" Then
		strQuery = strQuery & " AND userId="&SQLClean(session("userId"),"N","S")
	End If
	If notebookId <> 0 Then
		strQuery = strQuery & " AND notebookId="&SQLClean(notebookId,"N","S")
	End if
	If statusId <> 0 Then
		strQuery = strQuery & " AND statusId="&SQLClean(statusId,"N","S")
	End If
	If collection <> "" Then
		strQuery = strQuery & " AND collection LIKE '%"&Replace(SQLClean(collection,"T","S"),"'","")&"%'"
	End If
	
	strQuery = strQuery &  " ORDER BY " & Replace(SQLClean(sortBy,"T","S"),"'","") & " " & Replace(SQLClean(sortDir,"T","S"),"'","")

	

	
	Call getconnected
	Set expRec = server.CreateObject("ADODB.RecordSet")
	expRec.open strQuery,conn,3,3
End if
%>
<!-- #include file="_inclds/header-tool.asp"-->
<!-- #include file="_inclds/nav_tool.asp"-->


<script type="text/javascript">
$(document).ready(function() {
	$("#RequestDropDown").change(function() {
		if($.trim($("#RequestDropDown").find(":selected").text()) == "<%=newUserSupportRequestLabel%>")
			$(".newUserRequest").css("display","block");
		else
			$(".newUserRequest").css("display","none");
	})
	.trigger("change");
});

function clickSubmit() {
	document.getElementById("submitButton").disabled = true;
	document.getElementById("frmSubmit").value = "1";
	document.getElementById("form1").submit();
	return false;
}
</script>



<table width="100%"><tr><td width="50%" valign="top">



<%
If request.Form("frmSubmit") <> "" Then

	fName = request.Form("fname")
	lName = request.Form("lname")
	email = request.Form("email")
	company = request.Form("company")
	title = request.Form("title")
	phone = request.Form("phone")
	req = request.Form("RequestDropDown")
	requestText = request.Form("requestText")
	requestSubject = request.Form("requestSubject")
	newUserFirstName = request.Form("newUserSupportRequestFirstName")
	newUserLastName = request.Form("newUserSupportRequestLastName")
	newUserEmail = request.Form("newUserSupportRequestEmail")

	If fName = "" Then
		efields = efields & "fname,"
	End If
	If lName = "" Then
		efields = efields & "lname,"
	End if	
	If Not validateEmail(email) Then
		efields = efields & "email,"
		email = ""
	End If
	If company = "" Then
		efields = efields & "company,"
	End If
	If req = "" Then
		efields = efields & "req,"
	End If
	If requestSubject = "" Then
		efields = efields & "requestSubject,"
	End If
	
	If req = newUserSupportRequestLabel Then
		If newUserFirstName = "" Then
			efields = efields & "newUserFirstName,"
		End If
		If newUserLastName = "" Then
			efields = efields & "newUserLastName,"
		End If
		If newUserEmail = "" Then
			efields = efields & "newUserEmail,"
		End If
	Else
		' Can only be blank if the user is not requesting a new user account
		If requestText = "" Then
			efields = efields & "requestText,"
		End If
	End If

	If efields = "" then
		strBody = strBody & "Name: " & fName & " " & lname &"<br/>"
		strBody = strBody & "Email: " & email & "<br/>"
		strBody = strBody & "Company: " & company & "<br/>"
		strBody = strBody & "Title: " & title & "<br/>"
		strBody = strBody & "Phone: " & phone & "<br/>"
		strBody = strBody & "Request Type: " & req & "<br/>"
		
		If req = newUserSupportRequestLabel Then
			strBody = strBody & "New User First Name: " & newUserFirstName & "<br/>"
			strBody = strBody & "New User Last Name: " & newUserLastName & "<br/>"
			strBody = strBody & "New User Email Address: " & newUserEmail & "<br/>"
		End If
		
		strBody = strBody & "Support Request: " & "<br/>" & Replace(requestText,vbcrlf,"<br/>") & "<br/>" & "<br/>" & request.Form("prevReferer")

		If session("ccAdminsOnSupport") Then
			Call getconnected
			Set rec = server.CreateObject("ADODB.RecordSet")
			strQuery = "SELECT * FROM usersView WHERE companyId="&SQLClean(session("companyId"),"N","S")&" AND roleNumber=1 AND enabled=1" 
			rec.open strQuery,conn,adOpenStatic,adLockReadOnly
			Do While Not rec.eof
				ccList = ccList & "," &rec("email")
				rec.movenext
			Loop
			rec.close
			Set rec = nothing
			Call disconnect
		End If

		'TODO do something with CC List
		Set d = JSON.parse("{}")
		d.Set "subject", HTMLDecodeUnicode(requestSubject)
		d.Set "text", strBody
		d.Set "category", 1 ' arxspan category
		d.Set "priority", 4 ' low priority
		d.Set "email", email
		d.Set "name", fName & " " & lName
		d.Set "cc", ccList
		data = JSON.stringify(d)

		set xmlhttp = server.Createobject("MSXML2.ServerXMLHTTP")
		xmlhttp.Open "POST","https://support.arxspan.com/api/1.1/json/tickets/", True, "f29e7cb75c8b4fff841721b67b9d69cb", "32355553959f483da635729824efaa06"
		xmlhttp.setRequestHeader "Content-Type", "application/json"
		xmlhttp.SetTimeouts 300000,300000,300000,300000
		xmlhttp.send data
		xmlhttp.waitForResponse(60)
		retStr = xmlhttp.responsetext
		if xmlhttp.status <> 200 then
			response.status = 500
		end if

	End if
End if
%>

<h1><%=contactArxspanSupportLabel%></h1>

<%If request.Form("frmSubmit") = "" Or efields <> "" then%>
<form class="chunkyForm" id="form1" name="form1" method="post" action="support-request.asp">
<input type="hidden" value="fname,lname,company,email,requestSubject" name="required" />

<table style="width:600px;">
<tr>
<td valign="top" style="width:300px;">
  <label for="fname"><%errorchktext firstNameLabel&": *","fname"%></LABEL>
              <INPUT type="text" id="fname" name="fname" maxlength="30" value="<%=session("firstName")%>"/>

  <label for="lname"><%errorchktext lastNameLabel&": *","lname"%></LABEL>
	<input type="text" name="lname" maxlength="30" value="<%=session("lastName")%>" />
  
  <label for="email"><%errorchktext emailLabel&": *","email"%></LABEL>
	<input type="text" name="email" maxlength="60" value="<%=session("email")%>"/>
</td>
<td>
  <label for="company"><%errorchktext companyLabel&": *","company"%></LABEL>
	<input type="text" name="company" maxlength="55"  value="<%=session("company")%>"/>
  
  <label for="title"><%=personsTitleLabel%>:</LABEL>
	<input type="text" name="title" maxlength="30" value="<%=session("title")%>"/>
  
  <label for="phone"><%=phoneNumberLabel%>:</LABEL>
	<input type="text" name="phone"  maxlength="30" value="<%=session("phone")%>"/>
 </td>
 </tr>
 <tr>
  <td colspan="2" style="width:300px;padding-top:20px;">  
  <label for="RequestDropDown"><%errorchktext typeOfRequestLabel&": *","req"%></LABEL>
	<select name="RequestDropDown" id="RequestDropDown" class="textGB">
			<option value="">
			&lt; <%=pleaseSelectLabel%> &gt;
			</option>
			<%If session("role") = "Admin" Then%>
				<option value="<%=newUserSupportRequestLabel%>"<%If req=newUserSupportRequestLabel then%> SELECTED<%End if%>>
				<%=newUserSupportRequestLabel%>
				</option>
			<%End If%>
			<option value="<%=somethingIsNotWorkingLabel%>"<%If req=somethingIsNotWorkingLabel Or request.querystring("axcNum") <> "" then%> SELECTED<%End if%>>
			<%=somethingIsNotWorkingLabel%>
			</option>
			<option value="<%=iNeedHelpDoingSomethingLabel%>"<%If req=iNeedHelpDoingSomethingLabel then%> SELECTED<%End if%>>
			<%=iNeedHelpDoingSomethingLabel%>
			</option>
			<option value="<%=newFeatureRequestLabel%>"<%If req=newFeatureRequestLabel then%> SELECTED<%End if%>>
			<%=newFeatureRequestLabel%>
			</option>
			<option value="<%=otherLabel%>"<%If req=otherLabel then%> SELECTED<%End if%>>
			<%=otherLabel%>
			</option>
	</select>
  </td>
</tr>
 <tr class="newUserRequest" style="display:none;">
  <td colspan="2" style="width:300px;">
    <label for="newUserSupportRequestFirstName"><%=newUserSupportRequestFirstNameLabel%>: *</label>
    <INPUT type="text" id="newUserSupportRequestFirstName" name="newUserSupportRequestFirstName" maxlength="60" value=""/>
  </td>
</tr>
 <tr class="newUserRequest" style="display:none;">
  <td colspan="2" style="width:300px;">
    <label for="newUserSupportRequestLastName"><%=newUserSupportRequestLastNameLabel%>: *</label>
    <INPUT type="text" id="newUserSupportRequestLastName" name="newUserSupportRequestLastName" maxlength="60" value=""/>
  </td>
</tr>
 <tr class="newUserRequest" style="display:none;">
  <td colspan="2" style="width:300px;">
    <label for="newUserSupportRequestEmail"><%=newUserSupportRequestEmailLabel%>: *</label>
    <INPUT type="text" id="newUserSupportRequestEmail" name="newUserSupportRequestEmail" maxlength="60" value=""/>
  </td>
</tr>
<tr>
<td>

<label for="requestSubject"><%errorchktext subjectLabel&": *","requestSubject"%></LABEL>
<INPUT type="text" id="requestSubject" name="requestSubject" maxlength="50" value="<%=requestSubject%>"/>
<label for="requestText"><%errorchktext requestLabel&": *","requestText"%></LABEL>
<%
If requestText = "" And request.querystring("axcNum") <> "" Then
	requestText = vbcrlf&vbcrlf&vbcrlf&"-------------------------------------------------"&vbcrlf&"Please write above this line."&vbcrlf&"AXCNUM: "&request.querystring("axcNum")
End if
If request.querystring("pdfErr") <> "" Then
	expId = request.queryString("expId")
	typeId = request.querystring("expType")
	expType = "Chemistry"
	Select Case typeId
		Case "2"
			expType = "Biology"
		Case "3"
			expType = "Concept"
		Case "4"
			expType = "Analytical"
	End Select
	requestText = "The PDF for " & expType & " Experiment " & expId & " could not be generated."
End if
%>
<textarea name="requestText" style="width:350px;height:80px;font-family:arial,helvetica,sans;margin-bottom:18px;"><%=requestText %></textarea>

<input class="btn" id="submitButton" onclick="clickSubmit();" value="<%=submitLabel%>" /> 

<input type="hidden" name="frmSubmit" id="frmSubmit" value=""/>
<input type="hidden" name="prevReferer" <%If InStr(request.servervariables("HTTP_REFERER"),"support-request")<=0 then%>value="<%=request.servervariables("HTTP_REFERER")%>"<%else%>value="<%=request.Form("prevReferer")%>"<%End if%>/>
</td></tr></table>

</form>
<%else%>
<p>We have received your request.  An Arxspan representative will respond to you shortly.</p>
<%End if%>






</td></tr></table>
<!-- #include file="_inclds/footer-tool.asp"-->