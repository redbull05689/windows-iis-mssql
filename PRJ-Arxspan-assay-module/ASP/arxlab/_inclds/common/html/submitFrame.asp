<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<iframe <%If inframe then%>name="submitFrameFrame" id="submitFrameFrame"<%else%>name="submitFrame" id="submitFrame"<%End if%> style="border:5px solid black;width:800px;<%If Not session("debug") then%>height:2px;visibility:hidden;<%else%>height:200px;<%End if%>" src="<%=mainAppPath%>/static/blank.html"></iframe>

<form id="hungSaveForm" method="post" target="submitFrame2" action="<%=mainAppPath%>/experiments/ajax/do/hungSaveSendEmail.asp">
<input type="hidden" id="hungSaveFrameHTML" name="hungSaveFrameHTML" value="">
<input type="hidden" name="hungSaveExperimentId" value="<%=experimentId%>">
<input type="hidden" name="hungSaveRevisionId" value="<%=maxRevisionNumber%>">
<input type="hidden" name="hungSaveUserName" value="<%=session("firstName")&" "&session("lastName")%>">
<input type="hidden" name="hungSaveCompanyName" value="<%=session("companyName")%>">
<input type="hidden" name="hungSaveSerial" value="<%=hungSaveSerial%>">
</form>

<iframe <%If inframe then%>name="submitFrame2Frame" id="submitFrame2Frame"<%else%>name="submitFrame2" id="submitFrame2"<%End if%> style="border:5px solid black;width:800px;<%If Not session("debug") then%>height:2px;visibility:hidden;<%else%>height:200px;<%End if%>" src="<%=mainAppPath%>/static/blank.html"></iframe>