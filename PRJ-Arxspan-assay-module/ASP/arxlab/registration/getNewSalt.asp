<!-- #include virtual="/_inclds/sessionInit.asp" -->
<%sectionId="reg"%>
<!-- #include file="../_inclds/globals.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->

<%
saltNum = request.querystring("saltNumber")
%>



   <div id = "salt_<% =saltNum %>_edit">
<label for="salt_<%=saltNum%>_cdId">Salt</label>
<select id="salt_<%=saltNum%>_cdId" name="salt_<%=saltNum%>_cdId">
<option value="0">--- SELECT ---</option>
<%
regSaltsTable = getCompanySpecificSingleAppConfigSetting("regSaltsTable", session("companyId"))
call getconnectedJchemReg
Set rec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT cd_id,name FROM "&regSaltsTable& " WHERE 1=1 ORDER BY upper(name) ASC"
rec.open strQuery,jchemRegConn,3,3
Do While Not rec.eof
%>
	<option value="<%=rec("cd_id")%>"><%=rec("name")%></option>
<%
	rec.movenext
loop
Call disconnectJchemReg
%>
</select>
<label for="salt_<%=saltNum%>_multiplicity">Multiplicity</label>
<input type="text" name="salt_<%=saltNum%>_multiplicity" class="multiplicVal" id="salt_<%=saltNum%>_multiplicity" value="1.0" >
</div>
