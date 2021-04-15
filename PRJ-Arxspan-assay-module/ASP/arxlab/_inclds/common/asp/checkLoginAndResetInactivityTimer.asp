<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%If session("sessionTimeout") then%>
<script type="text/javascript">
allowReset = true;
actionsHappened = false;
mainAppPath = '<%=mainAppPath%>';
document.checkActionsTimer = null;

function cancelCheckActionsTimer() {
	clearInterval(document.checkActionsTimer);
}

function setCheckActionsTimer() {
	cancelCheckActionsTimer();
	document.checkActionsTimer = setInterval(updateActivity, 15000);
}

function updateActivity(){
	isUserLoggedIn()
	.then(function(isLoggedIn) {
		if(isLoggedIn) {
			showInactivityDialog().then(function(){
				if (actionsHappened && allowReset){
					resetActivityTimer();
				}
			});
		}
	});
}

function handleVisibilityChange() {
	cancelCheckActionsTimer();
	if(!document.hidden) {
		updateActivity();
		setCheckActionsTimer();
	}
}

function isUserLoggedIn() {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "<%=mainAppPath%>/ajax_checkers/isloggedin.asp?random="+Math.random(),
			type: "GET",
			success: function(data)
			{
				if (data == "false") {
					unsavedChanges = false;
					killIntervals();
					resolve(false);
					window.location = '<%=mainAppPath%>/logout.asp'
				}
				
				resolve(true);
			},
			error: function(error, textStatus, errorThrown)
			{
				console.error("ERROR isUserLoggedIn()");
				reject(false);
			},
			complete: function()
			{
			}
		});
	});
}

function resetActivityTimer() {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "<%=mainAppPath%>/ajax_doers/resetInactivityTimer.asp?rand="+Math.random(),
			type: "GET",
			success: function(data)
			{
				resolve(true);
			},
			error: function(error, textStatus, errorThrown)
			{
				console.error("ERROR resetActivityTimer()");
				reject(false);
			},
			complete: function()
			{
				actionsHappened = false;
			}
		});
	});
}

function showInactivityDialog() {
	return new Promise(function(resolve, reject) {
		$.ajax({
			url: "<%=mainAppPath%>/ajax_doers/getInactivityTime.asp?rand="+Math.random(),
			type: "GET",
			success: function(data)
			{
				if(data/60 >= <%=session("sessionTimeoutMinutes")%>){
					resolve(false);
					window.location = '<%=mainAppPath%>/logout.asp'
				}
				
				if (allowReset){
					if(data / 60 >= <%=session("sessionTimeoutMinutes")%> - 2) {
						allowReset = false;
						showPopup('inactivityDiv');
						window.setTimeout((function(numSeconds) {
							function decrementTimer() {
								if (numSeconds%15 == 0) {
									$.get("<%=mainAppPath%>/ajax_doers/getInactivityTime.asp?rand="+Math.random())
									.done(function( data ) {
										numSeconds = <%=session("sessionTimeoutMinutes")%>*60-data;
									});
								}
								
								if (numSeconds >=0){
									document.getElementById("expireSeconds").innerHTML = numSeconds;
									window.setTimeout(decrementTimer,1000);
									
									if (numSeconds==0){
										window.location = '<%=mainAppPath%>/logout.asp'
									}
									numSeconds -= 1;
								}
							}
							
							return decrementTimer;
						})(<%=session("sessionTimeoutMinutes")%>*60-data),100)
					}
				}
				
				resolve(true);
			},
			error: function(error, textStatus, errorThrown)
			{
				console.error("ERROR showInactivityDialog()");
				reject(false);
			},
			complete: function()
			{
			}
		});
	});
}

$(document).ready(function () {
    $(this).mousemove(function (e) {
        actionsHappened = true;
    });
    $(this).keypress(function (e) {
        actionsHappened = true;
    });
    $(this).scroll(function (e) {
        actionsHappened = true;
    });
    $(this).mousedown(function (e) {
        actionsHappened = true;
    });
	
	if (typeof document.addEventListener !== "undefined" && document.hidden !== undefined) {
		// Handle page visibility change   
		setTimeout(function() {
			document.addEventListener("visibilitychange", handleVisibilityChange, false);
		}, 5000);
	}
	
	setCheckActionsTimer();
});
</script>
<%
usersTable = getDefaultSingleAppConfigSetting("usersTable")
Set hRec = server.CreateObject("ADODB.RecordSet")
strQuery = "SELECT DATEDIFF(minute,lastActivityTime,GETUTCDATE()) as inactivityTime from "&usersTable&" WHERE id="&SQLClean(session("userId"),"N","S")
hRec.open strQuery,conn,0,-1
If Not IsNull(hRec("inactivityTime")) Then
	If hRec("inactivityTime")/60 >= session("sessionTimeoutMinutes") Then
		response.redirect(mainAppPath&"/logout.asp")
	Else
		Call getconnectedadm
		connAdm.execute("UPDATE users SET lastActivityTime=GETUTCDATE() WHERE id="&SQLClean(session("userId"),"N","S"))
		Call disconnectadm
	End if
End if
hRec.close
Set hRec = nothing
%>
<%End if%>
