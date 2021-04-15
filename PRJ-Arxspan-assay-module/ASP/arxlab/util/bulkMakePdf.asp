<!-- #include virtual="/_inclds/sessionInit.asp" -->
<!-- #include file='../_inclds/globals.asp'-->
<%Server.ScriptTimeout=108000%>
<%response.buffer=false%>

<%if 1=1 And session("companyId")="1" then%>
<%
If request.Form("sub") <> "" Then
Call getconnected
Call getconnectedadm
experimentType = request.Form("experimentType")
experimentIds = Split(request.Form("experimentIds"),vbcrlf)
Dim w
For w = 0 To UBound(experimentIds)
	exParts = Split(experimentIds(w),"-")
	experimentId = exParts(0)
	revisionNumber = exParts(1)
	response.write(experimentId)
	response.write("<br/>")
	prefix = GetPrefix(experimentType)
	expTable = GetFullName(prefix, "experiments", true)
	strQuery = "SELECT revisionNumber FROM " & expTable & " WHERE id="&SQLClean(experimentId,"N","S")
	Set rec = server.CreateObject("ADODB.RecordSet")
	rec.open strQuery,conn,3,3
	trash = savePDF(experimentType,experimentId,revisionNumber,false,false,false)
Next
Call disconnect
Call disconnectadm
End if
%>


<form method="post" action="bulkMakePdf.asp">
<select id="experimentType" name="experimentType">
	<option value="1" <%If request.Form("experimentType")="1" then%>SELECTED<%End if%>>Chemistry</option>
	<option value="2" <%If request.Form("experimentType")="2" then%>SELECTED<%End if%>>Biology</option>
	<option value="3" <%If request.Form("experimentType")="3" then%>SELECTED<%End if%>>Concept</option>
	<option value="4" <%If request.Form("experimentType")="4" then%>SELECTED<%End if%>>Anal</option>
</select>
<br/>
experiments ids dash with revision number e.g. 12312-1
<br/>
<textarea id="experimentIds" name="experimentIds" rows="50" cols="80"><%=request.Form("experimentIds")%></textarea>
<br/>
<input name="sub" type="submit">
</form>
<%end if%>