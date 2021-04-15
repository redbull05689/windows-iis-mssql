<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
theTab = request.querystring("tab")
%>
<%If theTab <> "" then%>
<script type="text/javascript">
function addEvent(obj, evType, fn){ 
 if (obj.addEventListener){ 
   obj.addEventListener(evType, fn, false); 
   return true; 
 } else if (obj.attachEvent){ 
   var r = obj.attachEvent("on"+evType, fn); 
   return r; 
 } else { 
   return false; 
 } 
}
<%
if session("hideNonCollabExperiments") then
	theTab = "attachmentTable"
end if
%>
		<%if theTab <> "reactionDiv" then%>
			try{addEvent(window,'load',function(){	showMainDiv('<%=theTab%>')})}catch(err){}
		<%end if%>
</script>
<%End if%>
<script type="text/javascript">
function addEvent(obj, evType, fn){ 
 if (obj.addEventListener){ 
   obj.addEventListener(evType, fn, false); 
   return true; 
 } else if (obj.attachEvent){ 
   var r = obj.attachEvent("on"+evType, fn); 
   return r; 
 } else { 
   return false; 
 } 
}

if (experimentType != 5) {
  addEvent(window,'load',function(){positionButtons();document.getElementById("submitRow").style.display = 'block'})
}
</script>